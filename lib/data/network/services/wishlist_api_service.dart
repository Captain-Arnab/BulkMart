import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class WishlistApiService {
  WishlistApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> add({
    required String productId,
  }) =>
      _client.post(
        APIClass.wishlistAdd,
        body: {'product_id': productId},
      );

  Future<ApiResult<Map<String, dynamic>>> list() =>
      _client.get(APIClass.wishlistList);

  Future<ApiResult<Map<String, dynamic>>> count() =>
      _client.get(APIClass.wishlistCount);

  Future<ApiResult<Map<String, dynamic>>> check({
    required String productId,
  }) =>
      _client.get(
        APIClass.wishlistCheck,
        queryParameters: {'product_id': productId},
      );

  Future<ApiResult<Map<String, dynamic>>> remove({
    required String productId,
  }) =>
      _client.post(
        APIClass.wishlistRemove,
        body: {'product_id': productId},
      );
}
