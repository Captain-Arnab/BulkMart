import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Local cart until cart API is wired. Exposed for bottom-nav badge later.
class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Map<String, int> _qtyById = {};

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  double get deliveryFee => _items.isEmpty ? 0 : 0; // TBD from API

  double get total => subtotal + deliveryFee;

  int quantityOf(String productId) => _qtyById[productId] ?? 0;

  void _syncQtyIndex() {
    _qtyById
      ..clear()
      ..addEntries(_items.map((e) => MapEntry(e.product.id, e.quantity)));
  }

  /// Adds one sellable unit; first add respects MOQ.
  void quickAdd(Product product) {
    final existing = quantityOf(product.id);
    if (existing == 0) {
      addProduct(product, quantity: product.moq);
    } else {
      updateQuantity(product.id, existing + 1);
    }
  }

  void quickDecrement(Product product) {
    final existing = quantityOf(product.id);
    if (existing <= 0) return;
    if (existing <= product.moq) {
      remove(product.id);
    } else {
      updateQuantity(product.id, existing - 1);
    }
  }

  void addProduct(Product product, {int? quantity}) {
    final qty = quantity ?? product.moq;
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      final next = _items[index].quantity + qty;
      _items[index] = _items[index].copyWith(quantity: next);
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }
    _syncQtyIndex();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index < 0) return;
    final moq = _items[index].product.moq;
    if (quantity < moq) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    _syncQtyIndex();
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    _syncQtyIndex();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _qtyById.clear();
    notifyListeners();
  }
}
