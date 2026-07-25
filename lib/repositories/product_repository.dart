import '../data/dummy/dummy_products.dart';
import '../models/product.dart';
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

/// Product catalog repository. Currently serves dummy data shaped like the API.
class ProductRepository {
  Future<Result<List<ProductCategory>>> fetchCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // Real call: GET ApiEndpoints.categories
    return const Success(DummyCatalog.categories);
  }

  Future<Result<PaginatedProducts>> fetchProducts({
    String? categoryId,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    // Real call: GET ApiEndpoints.products?page=&limit=&category_id=&q=

    var list = List<Product>.from(DummyCatalog.products);

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
      return Success(
        PaginatedProducts(
          items: const [],
          page: page,
          limit: limit,
          total: total,
          hasMore: false,
        ),
      );
    }
    final end = (start + limit).clamp(0, total);
    final slice = list.sublist(start, end);

    return Success(
      PaginatedProducts(
        items: slice,
        page: page,
        limit: limit,
        total: total,
        hasMore: end < total,
      ),
    );
  }

  Future<Result<Product>> fetchProduct(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Real call: GET ApiEndpoints.productDetail(id)
    try {
      final product = DummyCatalog.products.firstWhere((p) => p.id == id);
      return Success(product);
    } catch (_) {
      return const Failure('Product not found', statusCode: 404);
    }
  }
}
