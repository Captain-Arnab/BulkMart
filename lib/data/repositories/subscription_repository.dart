import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/data/repositories/payment_repository.dart';
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

  /// Merchant transaction id for `/check-status.php` (SUB_-prefixed when present).
  String get paymentReferenceId {
    final txn = transactionId?.trim() ?? '';
    if (txn.isNotEmpty) return txn;

    final order = orderId?.trim() ?? '';
    if (order.isNotEmpty) return order;

    final merchant = raw['merchantTransactionId']?.toString().trim() ?? '';
    if (merchant.isNotEmpty) return merchant;
    final inner = raw['data'];
    if (inner is Map) {
      final nested = inner['merchantTransactionId']?.toString().trim() ?? '';
      if (nested.isNotEmpty) return nested;
    }

    final sub = subscriptionId.trim();
    if (sub.isEmpty) return '';
    return sub.startsWith('SUB_') ? sub : 'SUB_$sub';
  }
}

abstract class SubscriptionRepository {
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptionPlans();
  Future<ApiResult<SubscriptionCreateData>> createSubscription({
    required String planId,
    required String productId,
    required String startDate,
  });

  /// Polls site-root `/check-status.php` until COMPLETED / FAILED.
  Future<ApiResult<bool>> verifySubscriptionPayment({
    required String transactionId,
  });
}

class ApiSubscriptionRepository implements SubscriptionRepository {
  ApiSubscriptionRepository({
    UrbanRootsApi? api,
    PaymentRepository? paymentRepository,
  })  : _api = api ?? UrbanRootsApi.instance,
        _payments = paymentRepository ?? ApiPaymentRepository();

  final UrbanRootsApi _api;
  final PaymentRepository _payments;

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
    required String transactionId,
  }) async {
    final txn = transactionId.trim();
    if (txn.isEmpty) {
      return const ApiFailure('Missing transactionId for payment check');
    }

    final result = await _payments.pollPaymentStatus(transactionId: txn);
    if (result is ApiFailure<PaymentStatusCheck>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final check = (result as ApiSuccess<PaymentStatusCheck>).data;
    return ApiSuccess(check.isCompleted);
  }
}
