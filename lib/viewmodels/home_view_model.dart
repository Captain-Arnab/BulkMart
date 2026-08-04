import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  final ProductRepository _productRepository;

  bool isLoading = false;
  String? error;
  List<Product> products = [];
  List<ProductCategory> categories = [];

  /// Home section order (exclude "All").
  static const homeSectionCategoryIds = [
    'green_vegetables',
    'root_vegetables',
    'seasonal_fruits',
    'herbs_leafy',
  ];

  Future<void> init() async {
    await Future.wait([loadCategories(), refresh()]);
  }

  Future<void> loadCategories() async {
    final result = await _productRepository.getCategories();
    result.when(
      success: (list) {
        categories = list;
        notifyListeners();
      },
      failure: (message, {statusCode}) {
        // Non-fatal — chips can fall back
      },
    );
  }

  Future<void> refresh() async {
    isLoading = true;
    error = null;

    final result = await _productRepository.getAllProducts();

    result.when(
      success: (list) {
        products = list;
        isLoading = false;
        notifyListeners();
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  /// First [limit] products for a category; empty if none.
  List<Product> productsForCategory(String categoryId, {int limit = 8}) {
    final list = products.where((p) => p.categoryId == categoryId).toList();
    if (list.length <= limit) return list;
    return list.sublist(0, limit);
  }

  ProductCategory? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
