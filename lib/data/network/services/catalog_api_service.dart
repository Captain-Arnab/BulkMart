import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class CatalogApiService {
  CatalogApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> listCategories() =>
      _client.get(APIClass.listCategories, token: TokenMode.none);

  Future<ApiResult<Map<String, dynamic>>> listAllProducts() =>
      _client.get(APIClass.getProducts, token: TokenMode.none);

  Future<ApiResult<Map<String, dynamic>>> productsByCategory({
    required String categoryId,
    required int limit,
    required int page,
  }) =>
      _client.post(
        APIClass.getByCategory,
        token: TokenMode.none,
        body: {
          'category_id': categoryId,
          'limit': limit,
          'page': page,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> productDetail({
    required String productId,
  }) =>
      _client.get(
        APIClass.productView,
        token: TokenMode.none,
        queryParameters: {'pd_id': productId},
      );

  Future<ApiResult<Map<String, dynamic>>> searchProducts({
    required String keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sort,
    required int page,
    required int limit,
  }) =>
      _client.post(
        APIClass.searchProducts,
        token: TokenMode.none,
        body: {
          'keyword': keyword,
          if (category != null) 'category': category,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (inStock != null) 'in_stock': inStock,
          if (sort != null) 'sort': sort,
          'page': page,
          'limit': limit,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> homeBanners() =>
      _client.get(APIClass.homeBanners, token: TokenMode.none);

  Future<ApiResult<Map<String, dynamic>>> browseVendors({
    String? category,
    String? pincode,
  }) =>
      _client.get(
        APIClass.vendorsList,
        token: TokenMode.none,
        queryParameters: {
          if (category != null) 'category': category,
          if (pincode != null) 'pincode': pincode,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> vendorDetail({
    required String vendorId,
  }) =>
      _client.get(
        APIClass.vendorProducts(vendorId),
        token: TokenMode.none,
      );

  Future<ApiResult<Map<String, dynamic>>> checkPincode({
    required String pincode,
  }) =>
      _client.post(
        APIClass.checkPincode,
        token: TokenMode.none,
        body: {'pincode': pincode},
      );

  Future<ApiResult<Map<String, dynamic>>> removePincode() =>
      _client.get(APIClass.removePincode);
}
