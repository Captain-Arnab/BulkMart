import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';

class SubscriptionCreateData {
  const SubscriptionCreateData({
    required this.subscriptionId,
    required this.totalDeliveries,
    required this.startDate,
    required this.endDate,
    this.message = '',
    this.paymentUrl,
    this.orderId,
    this.transactionId,
    this.amount,
    this.raw = const {},
  });

  final String subscriptionId;
  final String totalDeliveries;
  final String startDate;
  final String endDate;
  final String message;
  /// PhonePe checkout link from create.php (present when payment is required).
  final String? paymentUrl;
  /// Links this subscription to a payment/order record.
  final String? orderId;
  final String? transactionId;
  /// Authoritative upfront charge for the full term (from create.php).
  final double? amount;
  final Map<String, dynamic> raw;

  bool get requiresPayment =>
      paymentUrl != null && paymentUrl!.trim().isNotEmpty;

  /// Prefer txn_id when present; otherwise order_id (may be SUB_-prefixed).
  String get paymentReferenceId {
    final txn = transactionId?.trim() ?? '';
    if (txn.isNotEmpty) return txn;
    return orderId?.trim() ?? '';
  }
}

abstract class SubscriptionRepository {
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptionPlans();
  Future<ApiResult<SubscriptionCreateData>> createSubscription({
    required String planId,
    required String productId,
    required String startDate,
  });

  /// Confirms payment_status after PhonePe return (check-status.php).
  Future<ApiResult<bool>> verifySubscriptionPayment({
    String? orderId,
    String? txnId,
  });
}

class ApiSubscriptionRepository implements SubscriptionRepository {
  ApiSubscriptionRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptionPlans() async {
    final result = await _api.subscription.listPlans();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return ApiSuccess(parseSubscriptionPlans(data));
  }

  @override
  Future<ApiResult<SubscriptionCreateData>> createSubscription({
    required String planId,
    required String productId,
    required String startDate,
  }) async {
    final result = await _api.subscription.create(
      planId: planId,
      productId: productId,
      startDate: startDate,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final inner = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    return ApiSuccess(
      SubscriptionCreateData(
        subscriptionId: inner['subscription_id']?.toString() ??
            inner['id']?.toString() ??
            '',
        totalDeliveries: inner['total_deliveries']?.toString() ??
            inner['deliveries']?.toString() ??
            '',
        startDate: inner['start_date']?.toString() ?? startDate,
        endDate: inner['end_date']?.toString() ?? '',
        message: data['message']?.toString() ??
            'Subscription created successfully',
        paymentUrl: extractPaymentUrl(data),
        orderId: extractOrderId(data),
        transactionId: extractTxnId(data),
        amount: extractTotalAmount(data),
        raw: data,
      ),
    );
  }

  @override
  Future<ApiResult<bool>> verifySubscriptionPayment({
    String? orderId,
    String? txnId,
  }) async {
    final oid = orderId?.trim() ?? '';
    final tid = txnId?.trim() ?? '';
    if (oid.isEmpty && tid.isEmpty) {
      return const ApiFailure('Missing order_id / txn_id for payment check');
    }

    final result = await _api.payments.checkStatus(
      orderId: oid.isNotEmpty ? oid : null,
      txnId: tid.isNotEmpty ? tid : null,
    );

    if (result is ApiSuccess<Map<String, dynamic>>) {
      return ApiSuccess(_isPaymentStatusComplete(result.data));
    }

    // Fallback: numeric order_id → existing orders/detail payment check.
    if (oid.isNotEmpty) {
      final detail = await _api.orders.orderDetail(
        orderId: oid,
        txnId: tid.isNotEmpty ? tid : null,
      );
      if (detail is ApiSuccess<Map<String, dynamic>>) {
        return ApiSuccess(_isPaymentStatusComplete(detail.data));
      }
    }

    final failure = result as ApiFailure<Map<String, dynamic>>;
    return ApiFailure(failure.message, statusCode: failure.statusCode);
  }

  bool _isPaymentStatusComplete(Map<String, dynamic> data) {
    final inner =
        data['data'] is Map ? Map<String, dynamic>.from(data['data'] as Map) : null;

    for (final key in ['is_paid', 'paid', 'payment_complete']) {
      final value = data[key] ?? inner?[key];
      if (value == true || value == 1 || value?.toString() == '1') return true;
      if (value == false || value == 0 || value?.toString() == '0') return false;
    }

    // Prefer explicit payment fields over envelope `status` (API ok flag).
    final candidates = <String?>[
      data['payment_status']?.toString(),
      data['paymentStatus']?.toString(),
      data['txn_status']?.toString(),
      inner?['payment_status']?.toString(),
      inner?['paymentStatus']?.toString(),
      inner?['txn_status']?.toString(),
      inner?['status']?.toString(),
    ];

    for (final raw in candidates) {
      final verdict = _paymentStatusVerdict(raw);
      if (verdict != null) return verdict;
    }
    return false;
  }

  /// `true` paid, `false` unpaid/failed, `null` inconclusive.
  bool? _paymentStatusVerdict(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.toLowerCase().trim();
    if (value.contains('paid') ||
        value.contains('success') ||
        value.contains('complete') ||
        value.contains('captured') ||
        value == '1' ||
        value == 'true') {
      return true;
    }
    if (value.contains('fail') ||
        value.contains('cancel') ||
        value.contains('pending') ||
        value.contains('unpaid') ||
        value == '0' ||
        value == 'false') {
      return false;
    }
    return null;
  }
}
