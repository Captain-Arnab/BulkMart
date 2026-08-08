import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

enum BrowseSort { popularity, priceLowHigh, priceHighLow }

class CategoryBrowseViewModel extends ChangeNotifier {
  CategoryBrowseViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  final ProductRepository _productRepository;

  bool isLoading = false;
  String? error;
  List<Product> products = [];
  List<ProductCategory> categories = [];
  String selectedCategoryId = 'all';
  String searchQuery = '';

  double minPrice = 0;
  double maxPrice = 5000;
  double filterMinPrice = 0;
  double filterMaxPrice = 5000;
  bool inStockOnly = false;
  BrowseSort sort = BrowseSort.popularity;

  Timer? _debounce;

  int get activeFilterCount {
    var n = 0;
    if (filterMinPrice > minPrice || filterMaxPrice < maxPrice) n++;
    if (inStockOnly) n++;
    if (sort != BrowseSort.popularity) n++;
    return n;
  }

  Future<void> init({String? categoryId, String? query}) async {
    if (categoryId != null) selectedCategoryId = categoryId;
    if (query != null) searchQuery = query;
    await loadCategories();
    await refresh();
  }

  Future<void> loadCategories() async {
    final result = await _productRepository.getCategories();
    result.when(
      success: (list) {
        categories = list;
        notifyListeners();
      },
      failure: (_, {statusCode}) {},
    );
  }

  Future<void> refresh() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final q = searchQuery.trim();
    final result = q.isNotEmpty
        ? await _productRepository.searchProducts(q)
        : selectedCategoryId != 'all'
            ? await _productRepository.getProductsByCategory(selectedCategoryId)
            : await _productRepository.getAllProducts();

    result.when(
      success: (items) {
        var list = items;
        if (q.isNotEmpty && selectedCategoryId != 'all') {
          list = list.where((p) => p.categoryId == selectedCategoryId).toList();
        }
        products = _applyLocalFilters(list);
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

  List<Product> _applyLocalFilters(List<Product> source) {
    var list = source.where((p) {
      final price = p.displayPrice;
      if (price < filterMinPrice || price > filterMaxPrice) {
        return false;
      }
      if (inStockOnly && p.stockCount <= 0) return false;
      return true;
    }).toList();

    switch (sort) {
      case BrowseSort.priceLowHigh:
        list.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
      case BrowseSort.priceHighLow:
        list.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
      case BrowseSort.popularity:
        break;
    }
    return list;
  }

  void selectCategory(String id) {
    if (selectedCategoryId == id) return;
    selectedCategoryId = id;
    refresh();
  }

  /// Apply an external intent (shell tab deep-link) even if values are unchanged.
  void applyBrowseIntent({String? categoryId, String? query}) {
    if (categoryId != null) selectedCategoryId = categoryId;
    if (query != null) searchQuery = query;
    refresh();
    notifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), refresh);
    notifyListeners();
  }

  void applyFilters({
    required double min,
    required double max,
    required bool stockOnly,
    required BrowseSort sortBy,
  }) {
    filterMinPrice = min;
    filterMaxPrice = max;
    inStockOnly = stockOnly;
    sort = sortBy;
    refresh();
  }

  void resetFilters() {
    filterMinPrice = minPrice;
    filterMaxPrice = maxPrice;
    inStockOnly = false;
    sort = BrowseSort.popularity;
    refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
