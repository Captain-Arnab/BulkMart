import '../core/config/app_config.dart';
import '../data/mock/mock_products.dart';
import '../models/product.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/result.dart';

// TODO: When backend API is ready, implement the real HTTP calls in
// ApiProductRepository (already scaffolded below) and flip kDemoMode to false
// in app_config.dart — no screen-level code should need to change.

/// Screens call only these catalog methods — never Dio / mock data directly.
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

/// Demo implementation — reads [MockProducts].
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

/// Live API implementation — stubs until backend catalog endpoints are ready.
class ApiProductRepository implements ProductRepository {
  ApiProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<ProductCategory>>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.categories);
      final raw =
          response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      final list = raw
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Product>>> getAllProducts() async {
    // TODO: Wire to GET /products (paginated) and flatten/map to [Product].
    throw UnimplementedError('ApiProductRepository.getAllProducts');
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    // TODO: Wire to GET /products?category_id=… 
    throw UnimplementedError('ApiProductRepository.getProductsByCategory');
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    // TODO: Wire to GET /products?q=…
    throw UnimplementedError('ApiProductRepository.searchProducts');
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.productDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return Success(Product.fromJson(data));
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
