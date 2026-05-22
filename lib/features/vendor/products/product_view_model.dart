import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/vendor_repository.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({VendorRepository? repository})
      : _repository = repository ?? MockVendorRepository();

  final VendorRepository _repository;

  UiState<List<VendorProduct>> productsState = const UiLoading();
  UiState<VendorProduct?> detailState = const UiLoading();
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  List<VendorProduct> get filteredProducts {
    if (productsState is! UiSuccess<List<VendorProduct>>) return [];
    final list = (productsState as UiSuccess<List<VendorProduct>>).data;
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q))
        .toList();
  }

  Future<void> loadProducts({bool simulateError = false}) async {
    productsState = const UiLoading();
    notifyListeners();
    try {
      if (simulateError) throw Exception('Failed to load products');
      final products = await _repository.getProducts();
      productsState = UiSuccess(products);
    } catch (e) {
      productsState = UiError<List<VendorProduct>>(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadProductDetail(String id) async {
    detailState = const UiLoading();
    notifyListeners();
    try {
      final product = await _repository.getProductById(id);
      if (product == null) {
        detailState = const UiError('Product not found');
      } else {
        detailState = UiSuccess(product);
      }
    } catch (e) {
      detailState = UiError(e.toString());
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await loadProducts();
      return true;
    } catch (e) {
      productsState = UiError<List<VendorProduct>>(e.toString());
      notifyListeners();
      return false;
    }
  }
}
