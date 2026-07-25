import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  final ProductRepository _productRepository;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;
  List<Product> products = [];
  List<ProductCategory> categories = [];
  String? selectedCategoryId = 'all';
  String searchQuery = '';

  int _page = 1;
  bool hasMore = true;
  static const _limit = 20;

  Timer? _debounce;

  Future<void> init() async {
    await Future.wait([loadCategories(), refresh()]);
  }

  Future<void> loadCategories() async {
    final result = await _productRepository.fetchCategories();
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
    _page = 1;
    hasMore = true;
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _productRepository.fetchProducts(
      categoryId: selectedCategoryId,
      query: searchQuery,
      page: _page,
      limit: _limit,
    );

    result.when(
      success: (page) {
        products = page.items;
        hasMore = page.hasMore;
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

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;
    isLoadingMore = true;
    notifyListeners();

    final next = _page + 1;
    final result = await _productRepository.fetchProducts(
      categoryId: selectedCategoryId,
      query: searchQuery,
      page: next,
      limit: _limit,
    );

    result.when(
      success: (page) {
        _page = next;
        products = [...products, ...page.items];
        hasMore = page.hasMore;
        isLoadingMore = false;
        notifyListeners();
      },
      failure: (message, {statusCode}) {
        isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId ?? 'all';
    refresh();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      refresh();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
