import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class CouponsApiService {
  CouponsApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> list() =>
      _client.get(APIClass.couponsList, token: TokenMode.none);

  Future<ApiResult<Map<String, dynamic>>> apply({
    required String couponCode,
    required double amount,
  }) =>
      _client.post(
        APIClass.couponsApply,
        token: TokenMode.none,
        body: {'coupon_code': couponCode, 'amount': amount},
      );

  /// Server always returns zero discount — reset client-side on call.
  Future<ApiResult<Map<String, dynamic>>> remove() =>
      _client.post(APIClass.couponsRemove, token: TokenMode.none);
}
