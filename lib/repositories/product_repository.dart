import '../core/config/app_config.dart';
import '../data/mock/mock_products.dart';
import '../models/product.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/result.dart';

class PaginatedProducts {
  const PaginatedProducts({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  final List<Product> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
}

/// Product catalog repository. Demo vs live is controlled by [AppConfig.kDemoMode].
class ProductRepository {
  ProductRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  Future<Result<List<ProductCategory>>> fetchCategories() async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return const Success(MockProducts.categories);
    }

    try {
      final response = await _apiClient!.dio.get(ApiEndpoints.categories);
      final raw = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      final list = raw
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<PaginatedProducts>> fetchProducts({
    String? categoryId,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return Success(_paginateMock(
        categoryId: categoryId,
        query: query,
        page: page,
        limit: limit,
      ));
    }

    try {
      final response = await _apiClient!.dio.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null && categoryId != 'all') 'category_id': categoryId,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      final rawItems = data['items'] as List<dynamic>? ?? data['products'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = (data['total'] as num?)?.toInt() ?? items.length;
      return Success(
        PaginatedProducts(
          items: items,
          page: page,
          limit: limit,
          total: total,
          hasMore: page * limit < total,
        ),
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Product>> fetchProduct(String id) async {
    if (AppConfig.kDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        return Success(MockProducts.byId(id));
      } catch (_) {
        return const Failure('Product not found', statusCode: 404);
      }
    }

    try {
      final response = await _apiClient!.dio.get(ApiEndpoints.productDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return Success(Product.fromJson(data));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  PaginatedProducts _paginateMock({
    String? categoryId,
    String? query,
    required int page,
    required int limit,
  }) {
    var list = List<Product>.from(MockProducts.products);

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }

    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }

    final total = list.length;
    final start = (page - 1) * limit;
    if (start >= total) {
      return PaginatedProducts(
        items: const [],
        page: page,
        limit: limit,
        total: total,
        hasMore: false,
      );
    }
    final end = (start + limit).clamp(0, total);
    return PaginatedProducts(
      items: list.sublist(start, end),
      page: page,
      limit: limit,
      total: total,
      hasMore: end < total,
    );
  }
}
