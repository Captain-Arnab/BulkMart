import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

abstract class WishlistRepository {
  Future<ApiResult<void>> addToWishlist(String productId);
  Future<ApiResult<void>> removeFromWishlist(String productId);
  Future<ApiResult<List<Map<String, dynamic>>>> getWishlist();
  Future<ApiResult<int>> getWishlistCount();
  Future<ApiResult<bool>> isInWishlist(String productId);
}

class ApiWishlistRepository implements WishlistRepository {
  ApiWishlistRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<void>> addToWishlist(String productId) async {
    final result = await _api.wishlist.add(productId: productId.trim());
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> removeFromWishlist(String productId) async {
    final result = await _api.wishlist.remove(productId: productId.trim());
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> getWishlist() async {
    final result = await _api.wishlist.list();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final items = extractList(data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return ApiSuccess(items);
  }

  @override
  Future<ApiResult<int>> getWishlistCount() async {
    final result = await _api.wishlist.count();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final count = int.tryParse(
          data['count']?.toString() ??
              data['data']?.toString() ??
              '0',
        ) ??
        0;
    // Nested count: data: { count: N }
    if (data['data'] is Map) {
      final inner = Map<String, dynamic>.from(data['data'] as Map);
      final nested = int.tryParse(inner['count']?.toString() ?? '');
      if (nested != null) return ApiSuccess(nested);
    }
    return ApiSuccess(count);
  }

  @override
  Future<ApiResult<bool>> isInWishlist(String productId) async {
    final id = productId.trim();
    if (id.isEmpty) return const ApiSuccess(false);

    final result = await _api.wishlist.check(productId: id);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    var flag = data['in_wishlist'];
    if (data['data'] is Map) {
      flag ??= (data['data'] as Map)['in_wishlist'];
    }
    final listed = flag == true ||
        flag?.toString() == '1' ||
        flag?.toString().toLowerCase() == 'true';
    return ApiSuccess(listed);
  }
}
