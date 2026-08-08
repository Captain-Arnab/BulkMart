class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.unit,
    required this.moq,
    this.price,
    this.stock,
    this.imageUrl,
    this.batchNo,
    this.itemCode,
    this.description,
    this.inStock = true,
  });

  final String id;
  final String name;

  /// Display category name, e.g. "Green Vegetables".
  final String category;

  /// Stable id used for filtering / navigation, e.g. "green_vegetables".
  final String categoryId;

  /// Sell unit, e.g. "per kg", "per bunch".
  final String unit;

  final int moq;

  /// Wholesale price — nullable until backend pricing is wired.
  final double? price;

  /// Available stock — nullable until backend inventory is wired.
  final int? stock;

  final String? imageUrl;

  /// Backend/admin-only — do not surface in customer UI.
  final String? batchNo;

  /// Backend/admin-only — do not surface in customer UI.
  final String? itemCode;

  final String? description;
  final bool inStock;

  /// Short noun for badges ("kg", "bunch") derived from [unit].
  String get unitNoun {
    final cleaned = unit.toLowerCase().replaceFirst(RegExp(r'^per\s+'), '').trim();
    return cleaned.isEmpty ? 'unit' : cleaned;
  }

  /// Price used in cart math when backend price is still a placeholder.
  double get displayPrice => price ?? 0;

  int get stockCount => stock ?? 0;

  /// Deterministic Picsum fallback when LoremFlickr is slow/unavailable.
  String get fallbackImageUrl {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'https://picsum.photos/seed/$slug/400/400';
  }

  String get primaryImageUrl =>
      (imageUrl != null && imageUrl!.isNotEmpty) ? imageUrl! : fallbackImageUrl;

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryId,
    String? unit,
    int? moq,
    double? price,
    int? stock,
    String? imageUrl,
    String? batchNo,
    String? itemCode,
    String? description,
    bool? inStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      moq: moq ?? this.moq,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      batchNo: batchNo ?? this.batchNo,
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      inStock: inStock ?? this.inStock,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? json['categoryId']?.toString() ?? '',
      unit: json['unit']?.toString() ??
          json['unit_size']?.toString() ??
          json['unitSize']?.toString() ??
          'per kg',
      moq: ((json['moq'] ?? 1) as num).toInt(),
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : json['wholesale_price'] != null
              ? (json['wholesale_price'] as num).toDouble()
              : json['wholesalePrice'] != null
                  ? (json['wholesalePrice'] as num).toDouble()
                  : null,
      stock: json['stock'] != null
          ? (json['stock'] as num).toInt()
          : json['stock_count'] != null
              ? (json['stock_count'] as num).toInt()
              : json['stockCount'] != null
                  ? (json['stockCount'] as num).toInt()
                  : null,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      batchNo: json['batch_no']?.toString() ?? json['batchNo']?.toString(),
      itemCode: json['item_code']?.toString() ?? json['itemCode']?.toString(),
      description: json['description']?.toString(),
      inStock: json['in_stock'] as bool? ?? json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'category_id': categoryId,
        'unit': unit,
        'moq': moq,
        if (price != null) 'price': price,
        if (stock != null) 'stock': stock,
        if (imageUrl != null) 'image_url': imageUrl,
        if (batchNo != null) 'batch_no': batchNo,
        if (itemCode != null) 'item_code': itemCode,
        if (description != null) 'description': description,
        'in_stock': inStock,
      };
}

class ProductCategory {
  const ProductCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
