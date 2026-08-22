import 'product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get lineTotal => product.displayPrice * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    if (json['product'] is Map<String, dynamic>) {
      return CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        quantity: ((json['quantity'] ?? json['qty'] ?? 1) as num).toInt(),
      );
    }
    // Order line / cart line without nested product object.
    final product = Product(
      id: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['product_name']?.toString() ??
          '',
      category: json['category_name']?.toString() ??
          json['category']?.toString() ??
          '',
      categoryId: json['category_id']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'per kg',
      moq: ((json['moq'] ?? 1) as num).toInt(),
      price: json['unit_price'] != null
          ? (json['unit_price'] as num).toDouble()
          : json['price'] != null
              ? (json['price'] as num).toDouble()
              : null,
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : null,
      imageUrl: json['image_url']?.toString(),
      inStock: json['in_stock'] as bool? ?? true,
    );
    return CartItem(
      product: product,
      quantity: ((json['quantity'] ?? json['qty'] ?? 1) as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}
