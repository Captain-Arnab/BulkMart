import '../core/config/app_config.dart';
import '../data/mock/mock_products.dart';
import '../models/product.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class ProductRepository {
  factory ProductRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) {
      return MockProductRepository();
    }
    return ApiProductRepository(apiClient: apiClient!);
  }

  Future<Result<List<ProductCategory>>> getCategories();

  Future<Result<List<Product>>> getAllProducts();

  Future<Result<List<Product>>> getProductsByCategory(String category);

  Future<Result<List<Product>>> searchProducts(String query);

  Future<Result<Product>> getProductById(String id);
}

class MockProductRepository implements ProductRepository {
  @override
  Future<Result<List<ProductCategory>>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const Success(MockProducts.categories);
  }

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return Success(List<Product>.from(MockProducts.products));
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (category.isEmpty || category == 'all') {
      return Success(List<Product>.from(MockProducts.products));
    }
    return Success(MockProducts.byCategory(category));
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return Success(MockProducts.search(query));
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    try {
      return Success(MockProducts.byId(id));
    } catch (_) {
      return const Failure('Product not found', statusCode: 404);
    }
  }
}

class ApiProductRepository implements ProductRepository {
  ApiProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Product> _parseProducts(dynamic data) {
    if (data is Map && data['products'] is List) {
      return (data['products'] as List)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (data is List) {
      return data
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return const [];
  }

  Future<Result<List<Product>>> _fetchProductsPage({
    int page = 1,
    int perPage = 50,
    String? categoryId,
    String? query,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (categoryId != null &&
              categoryId.isNotEmpty &&
              categoryId != 'all')
            'category_id': categoryId,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      return ApiEnvelope.parse(response, _parseProducts);
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<List<Product>>> _fetchAllPages({
    String? categoryId,
    String? query,
  }) async {
    final first = await _fetchProductsPage(
      page: 1,
      perPage: 50,
      categoryId: categoryId,
      query: query,
    );
    if (first is! Success<List<Product>>) return first;

    // Best-effort: if first page is full, pull page 2 as well (catalog is small).
    if (first.data.length >= 50) {
      final second = await _fetchProductsPage(
        page: 2,
        perPage: 50,
        categoryId: categoryId,
        query: query,
      );
      if (second is Success<List<Product>>) {
        return Success([...first.data, ...second.data]);
      }
    }
    return first;
  }

  @override
  Future<Result<List<ProductCategory>>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.categories);
      return ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['categories'] is List
            ? data['categories'] as List
            : data is List
                ? data
                : const [];
        return raw
            .map(
              (e) =>
                  ProductCategory.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<Product>>> getAllProducts() => _fetchAllPages();

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) {
    if (category.isEmpty || category == 'all') return _fetchAllPages();
    return _fetchAllPages(categoryId: category);
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) =>
      _fetchAllPages(query: query);

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final response =
          await _apiClient.dio.get(ApiEndpoints.productDetail(id));
      return ApiEnvelope.parse(response, (data) {
        if (data is Map && data['product'] is Map) {
          return Product.fromJson(
            Map<String, dynamic>.from(data['product'] as Map),
          );
        }
        return Product.fromJson(Map<String, dynamic>.from(data as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }
}
