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
    this.transactionId,
    this.amount,
    this.raw = const {},
  });

  final String subscriptionId;
  final String totalDeliveries;
  final String startDate;
  final String endDate;
  final String message;
  final String? paymentUrl;
  final String? transactionId;
  final double? amount;
  final Map<String, dynamic> raw;
}

abstract class SubscriptionRepository {
  Future<ApiResult<List<Map<String, dynamic>>>> getSubscriptionPlans();
  Future<ApiResult<SubscriptionCreateData>> createSubscription({
    required String planId,
    required String productId,
    required String startDate,
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
        transactionId: extractTxnId(data),
        amount: extractTotalAmount(data),
        raw: data,
      ),
    );
  }
}
