class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountLabel,
    required this.validUntil,
    required this.gradientColors,
    this.categoryId,
    this.minQty,
    this.textColor,
    this.featured = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String discountLabel;
  final DateTime validUntil;
  final List<int> gradientColors; // ARGB ints for const mock data
  final String? categoryId;
  final int? minQty;
  final int? textColor; // ARGB
  final bool featured;

  factory Offer.fromJson(Map<String, dynamic> json) {
    final colors = (json['gradient_colors'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [0xFF0B5C27, 0xFF12833B];
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      discountLabel: json['discount_label']?.toString() ??
          json['discountLabel']?.toString() ??
          '',
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 14)),
      gradientColors: colors,
      categoryId: json['category_id']?.toString() ?? json['categoryId']?.toString(),
      minQty: (json['min_qty'] as num?)?.toInt() ?? (json['minQty'] as num?)?.toInt(),
      textColor: (json['text_color'] as num?)?.toInt(),
      featured: json['featured'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'discount_label': discountLabel,
        'valid_until': validUntil.toIso8601String(),
        'gradient_colors': gradientColors,
        if (categoryId != null) 'category_id': categoryId,
        if (minQty != null) 'min_qty': minQty,
        if (textColor != null) 'text_color': textColor,
        'featured': featured,
      };
}
