class Product {
  final String id;
  final String name;
  final String price;
  final String grams;
  final String stock;
  final String imageUrl;
  final String packingType;
  final String gst;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.grams,
    required this.stock,
    required this.imageUrl,
    required this.packingType,
    required this.gst,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['pd_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      grams: json['product_grams'] ?? '0g',
      stock: json['product_stock']?.toString() ?? '0',
      imageUrl: json['imageUrl'] ?? '',
      packingType: json['packing_type'] ?? '',
      gst: json['gst']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pd_id': id,
      'name': name,
      'price': price,
      'product_grams': grams,
      'product_stock': stock,
      'imageUrl': imageUrl,
      'packing_type': packingType,
      'gst': gst,
    };
  }

  // Helper method to get numeric grams value
  int get gramsValue {
    String numericString = grams.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericString) ?? 0;
  }

  // Helper method to get numeric price value
  double get priceValue {
    return double.tryParse(price) ?? 0.0;
  }
}