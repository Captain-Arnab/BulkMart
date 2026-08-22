import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../repositories/wishlist_repository.dart';

class WishlistViewModel extends ChangeNotifier {
  WishlistViewModel({
    required WishlistRepository wishlistRepository,
    required ProductRepository productRepository,
  })  : _wishlistRepository = wishlistRepository,
        _productRepository = productRepository;

  final WishlistRepository _wishlistRepository;
  final ProductRepository _productRepository;

  final Set<String> _ids = {};
  List<Product> products = [];
  bool isLoading = false;
  String? error;

  bool contains(String productId) => _ids.contains(productId);
  int get count => _ids.length;

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();
    final result = await _wishlistRepository.getProductIds();
    await result.when(
      success: (ids) async {
        _ids
          ..clear()
          ..addAll(ids);
        await _resolveProducts();
        isLoading = false;
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _resolveProducts() async {
    if (_ids.isEmpty) {
      products = [];
      return;
    }
    final all = await _productRepository.getAllProducts();
    all.when(
      success: (list) {
        products = list.where((p) => _ids.contains(p.id)).toList();
      },
      failure: (message, {statusCode, code, fields}) {
        products = [];
      },
    );
  }

  Future<void> toggle(String productId) async {
    final result = await _wishlistRepository.toggle(productId);
    await result.when(
      success: (ids) async {
        _ids
          ..clear()
          ..addAll(ids);
        await _resolveProducts();
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        notifyListeners();
      },
    );
  }

  Future<void> remove(String productId) async {
    final result = await _wishlistRepository.remove(productId);
    await result.when(
      success: (ids) async {
        _ids
          ..clear()
          ..addAll(ids);
        await _resolveProducts();
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        notifyListeners();
      },
    );
  }

  Future<void> refreshProducts() async {
    await _resolveProducts();
    notifyListeners();
  }
}
