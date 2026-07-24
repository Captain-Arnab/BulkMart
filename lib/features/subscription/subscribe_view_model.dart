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

  /// Latest create.php snapshot (updated on Retry — may be same or new sub).
  SubscriptionCreateData? pendingPayment;
  String pendingProductName = '';
  String pendingPlanName = '';

  /// Original selection — Retry Payment re-calls create.php with these.
  String pendingProductId = '';
  String pendingPlanId = '';
  String pendingStartDate = '';

  Map<String, dynamic>? selectedPlan;
  DateTime startDate =
      DateTime.now().add(const Duration(days: kSubscriptionMinLeadDays));

  bool get isLoadingPlans => plansState is UiLoading;
  bool get isCreating => createState is UiLoading;

  bool get canRetryPayment =>
      pendingProductId.isNotEmpty &&
      pendingPlanId.isNotEmpty &&
      pendingStartDate.isNotEmpty;

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

  /// Stores create.php fields + original selection before opening PhonePe.
  void capturePendingPayment(
    SubscriptionCreateData data, {
    required String productId,
    required String productName,
    required String planName,
    required String planId,
    required String startDate,
  }) {
    pendingPayment = data;
    pendingProductId = productId;
    pendingProductName = productName;
    pendingPlanName = planName;
    pendingPlanId = planId;
    pendingStartDate = startDate;
    createState = UiSuccess(data);
    notifyListeners();
  }

  void clearPendingPayment() {
    pendingPayment = null;
    pendingProductName = '';
    pendingPlanName = '';
    pendingProductId = '';
    pendingPlanId = '';
    pendingStartDate = '';
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

  /// Retry: call create.php again — backend dedupes pending (< ~18m) or issues
  /// a fresh subscription_id + payment_url when stale. Updates [pendingPayment].
  Future<SubscriptionCreateData?> retryCreate() async {
    if (!canRetryPayment) {
      createState = const UiError('Missing plan details to retry payment');
      notifyListeners();
      return null;
    }

    createState = const UiLoading();
    notifyListeners();

    final result = await _repository.createSubscription(
      planId: pendingPlanId,
      productId: pendingProductId,
      startDate: pendingStartDate,
    );

    if (result is ApiFailure<SubscriptionCreateData>) {
      createState = UiError(result.message);
      notifyListeners();
      return null;
    }

    final data = (result as ApiSuccess<SubscriptionCreateData>).data;
    pendingPayment = data;
    createState = UiSuccess(data);
    notifyListeners();
    return data;
  }

  /// Polls `/check-status.php` using the transaction id from the latest create.
  Future<bool> verifyPendingPayment() async {
    final data = pendingPayment;
    if (data == null) return false;

    final txn = data.paymentReferenceId;
    if (txn.isEmpty) return false;

    final result =
        await _repository.verifySubscriptionPayment(transactionId: txn);
    if (result is ApiFailure<bool>) return false;
    return (result as ApiSuccess<bool>).data;
  }
}
