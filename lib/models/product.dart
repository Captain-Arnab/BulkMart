class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.unitSize,
    required this.unitLabel,
    required this.wholesalePrice,
    required this.moq,
    required this.stockCount,
    this.moqDisplay,
    this.imageUrl,
    this.description,
    this.inStock = true,
  });

  final String id;
  final String name;
  final String category;
  final String categoryId;
  final String unitSize;
  final String unitLabel;
  final double wholesalePrice;
  final int moq;
  final String? moqDisplay;
  final int stockCount;
  final String? imageUrl;
  final String? description;
  final bool inStock;

  /// Compact stamp text, e.g. "25kg" / "15L"
  String get moqStamp {
    if (moqDisplay != null && moqDisplay!.isNotEmpty) return moqDisplay!;
    final parts = unitSize.split(' ');
    if (parts.length >= 2) return '${parts[0]}${parts[1]}';
    return unitSize;
  }

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? json['categoryId']?.toString() ?? '',
      unitSize: json['unit_size']?.toString() ?? json['unitSize']?.toString() ?? '',
      unitLabel: json['unit_label']?.toString() ?? json['unitLabel']?.toString() ?? 'unit',
      wholesalePrice: ((json['wholesale_price'] ?? json['wholesalePrice'] ?? 0) as num).toDouble(),
      moq: ((json['moq'] ?? 1) as num).toInt(),
      moqDisplay: json['moq_display']?.toString() ?? json['moqDisplay']?.toString(),
      stockCount: ((json['stock_count'] ?? json['stockCount'] ?? 0) as num).toInt(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      description: json['description']?.toString(),
      inStock: json['in_stock'] as bool? ?? json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'category_id': categoryId,
        'unit_size': unitSize,
        'unit_label': unitLabel,
        'wholesale_price': wholesalePrice,
        'moq': moq,
        if (moqDisplay != null) 'moq_display': moqDisplay,
        'stock_count': stockCount,
        if (imageUrl != null) 'image_url': imageUrl,
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
