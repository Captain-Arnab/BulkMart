import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/home/models/home_models.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;
import 'package:urban_roots/features/products/models/Product.dart';

abstract class HomeRepository {
  Future<List<HomeBanner>> fetchBanners();
  Future<List<Category>> fetchCategories();
  Future<List<Product>> fetchFeaturedProducts({int limit = 8});
  Future<List<Product>> fetchProductsByCategory({
    required String categoryId,
    int limit = 10,
    int page = 1,
  });
}

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository({UrbanRootsApi? api}) : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<List<HomeBanner>> fetchBanners() async {
    final result = await _api.catalog.homeBanners();
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw HomeRepositoryException(result.message);
    }
    return extractList((result as ApiSuccess<Map<String, dynamic>>).data)
        .whereType<Map>()
        .map((row) => HomeBanner.fromJson(Map<String, dynamic>.from(row)))
        .where((banner) => banner.imageUrl.trim().isNotEmpty)
        .map(
          (banner) => HomeBanner(
            imageUrl: resolveImageUrl(banner.imageUrl),
            link: banner.link,
          ),
        )
        .toList();
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final result = await _api.catalog.listCategories();
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw HomeRepositoryException(result.message);
    }
    return parseCategories((result as ApiSuccess<Map<String, dynamic>>).data);
  }

  @override
  Future<List<Product>> fetchFeaturedProducts({int limit = 8}) async {
    final result = await _api.catalog.listAllProducts();
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw HomeRepositoryException(result.message);
    }
    final products =
        parseProducts((result as ApiSuccess<Map<String, dynamic>>).data);
    if (products.length <= limit) return products;
    return products.sublist(0, limit);
  }

  @override
  Future<List<Product>> fetchProductsByCategory({
    required String categoryId,
    int limit = 10,
    int page = 1,
  }) async {
    final result = await _api.catalog.productsByCategory(
      categoryId: categoryId,
      limit: limit,
      page: page,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      throw HomeRepositoryException(result.message);
    }
    return parseProducts((result as ApiSuccess<Map<String, dynamic>>).data);
  }
}

class HomeRepositoryException implements Exception {
  HomeRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
