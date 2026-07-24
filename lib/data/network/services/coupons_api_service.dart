import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class CouponsApiService {
  CouponsApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> list() =>
      _client.get(APIClass.couponsList, token: TokenMode.none);

  /// Bearer-authenticated; persists applied coupon server-side.
  Future<ApiResult<Map<String, dynamic>>> apply({
    required String couponCode,
    required double amount,
  }) =>
      _client.post(
        APIClass.couponsApply,
        body: {'coupon_code': couponCode, 'amount': amount},
      );

  /// Removes the applied coupon and returns recalculated discount totals.
  Future<ApiResult<Map<String, dynamic>>> remove() =>
      _client.post(APIClass.couponsRemove);
}
