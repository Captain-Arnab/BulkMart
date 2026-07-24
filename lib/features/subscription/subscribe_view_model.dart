import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:intl/intl.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/subscription_repository.dart';

/// Minimum lead time before a subscription can start (calendar days from today).
/// Confirm with backend if create.php enforces a different rule.
const int kSubscriptionMinLeadDays = 1;

/// Creates a single-product subscription via [SubscriptionRepository].
/// Mirrors [BuyNowViewModel]: ChangeNotifier + [UiState], no cart involvement.
class SubscribeViewModel extends ChangeNotifier {
  SubscribeViewModel({SubscriptionRepository? repository})
      : _repository = repository ?? ApiSubscriptionRepository();

  final SubscriptionRepository _repository;

  UiState<List<Map<String, dynamic>>>? plansState;
  UiState<SubscriptionCreateData>? createState;

  /// Snapshot from create.php retained through PhonePe + retry (do not re-create).
  SubscriptionCreateData? pendingPayment;
  String pendingProductName = '';
  String pendingPlanName = '';

  Map<String, dynamic>? selectedPlan;
  DateTime startDate =
      DateTime.now().add(const Duration(days: kSubscriptionMinLeadDays));

  bool get isLoadingPlans => plansState is UiLoading;
  bool get isCreating => createState is UiLoading;

  DateTime get minStartDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(const Duration(days: kSubscriptionMinLeadDays));
  }

  DateTime get maxStartDate =>
      DateTime.now().add(const Duration(days: 365));

  String get startDateApi => DateFormat('yyyy-MM-dd').format(startDate);

  String get startDateDisplay => DateFormat('dd MMM yyyy').format(startDate);

  /// Estimated total from plans.php when the plan includes a price (> 0).
  double? get selectedPlanEstimatedTotal {
    final plan = selectedPlan;
    if (plan == null) return null;
    final parsed = double.tryParse(plan['price']?.toString() ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  Future<void> loadPlans() async {
    plansState = const UiLoading();
    selectedPlan = null;
    notifyListeners();

    final result = await _repository.getSubscriptionPlans();
    if (result is ApiFailure<List<Map<String, dynamic>>>) {
      plansState = UiError(result.message);
      notifyListeners();
      return;
    }

    final plans =
        (result as ApiSuccess<List<Map<String, dynamic>>>).data;
    selectedPlan = plans.isNotEmpty ? plans.first : null;
    plansState = UiSuccess(plans);
    notifyListeners();
  }

  void selectPlan(Map<String, dynamic> plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    final min = minStartDate;
    final clamped = date.isBefore(min) ? min : date;
    startDate = DateTime(clamped.year, clamped.month, clamped.day);
    notifyListeners();
  }

  void resetCreateState() {
    createState = null;
    notifyListeners();
  }

  /// Stores create.php fields before opening PhonePe (used for success UI + retry).
  void capturePendingPayment(
    SubscriptionCreateData data, {
    required String productName,
    required String planName,
  }) {
    pendingPayment = data;
    pendingProductName = productName;
    pendingPlanName = planName;
    createState = UiSuccess(data);
    notifyListeners();
  }

  void clearPendingPayment() {
    pendingPayment = null;
    pendingProductName = '';
    pendingPlanName = '';
    notifyListeners();
  }

  /// Calls `POST /subscription/create.php` with
  /// `{ plan_id, product_id, start_date }` (yyyy-MM-dd).
  Future<SubscriptionCreateData?> confirm({
    required String productId,
  }) async {
    final plan = selectedPlan;
    if (plan == null) return null;

    final planId =
        plan['id']?.toString() ?? plan['plan_id']?.toString() ?? '';
    if (planId.isEmpty) {
      createState = const UiError('Invalid plan selected');
      notifyListeners();
      return null;
    }

    createState = const UiLoading();
    notifyListeners();

    final result = await _repository.createSubscription(
      planId: planId,
      productId: productId,
      startDate: startDateApi,
    );

    if (result is ApiFailure<SubscriptionCreateData>) {
      createState = UiError(result.message);
      notifyListeners();
      return null;
    }

    final data = (result as ApiSuccess<SubscriptionCreateData>).data;
    createState = UiSuccess(data);
    notifyListeners();
    return data;
  }

  /// Confirms final payment via `/payments/check-status.php` using order_id / txn_id.
  Future<bool> verifyPendingPayment() async {
    final data = pendingPayment;
    if (data == null) return false;

    final orderId = data.orderId?.trim() ?? '';
    final txnId = data.transactionId?.trim() ?? '';
    // When create.php only returns order_id (often SUB_-prefixed), use it as txn too.
    final effectiveTxn = txnId.isNotEmpty
        ? txnId
        : (orderId.startsWith('SUB_') ? orderId : '');

    if (orderId.isEmpty && effectiveTxn.isEmpty) {
      // No server reference — cannot confirm; treat as unpaid.
      return false;
    }

    final result = await _repository.verifySubscriptionPayment(
      orderId: orderId.isNotEmpty ? orderId : null,
      txnId: effectiveTxn.isNotEmpty ? effectiveTxn : null,
    );

    if (result is ApiFailure<bool>) return false;
    return (result as ApiSuccess<bool>).data;
  }
}
