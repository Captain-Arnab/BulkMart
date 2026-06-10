import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class SubscriptionApiService {
  SubscriptionApiService({ApiClient? client})
      : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> listPlans() =>
      _client.get(APIClass.subscriptionPlans, token: TokenMode.none);

  Future<ApiResult<Map<String, dynamic>>> create({
    required String planId,
    required String productId,
    required String startDate,
  }) =>
      _client.post(
        APIClass.subscriptionCreate,
        body: {
          'plan_id': planId,
          'product_id': productId,
          'start_date': startDate,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> status() =>
      _client.get(APIClass.subscriptionStatus);
}
