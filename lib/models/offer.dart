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

    final discountType = json['discount_type']?.toString() ?? '';
    final discountValue = json['discount_value'];
    String label = json['discount_label']?.toString() ??
        json['discountLabel']?.toString() ??
        '';
    if (label.isEmpty && discountValue != null) {
      if (discountType == 'percentage') {
        label = '${(discountValue as num).toInt()}% OFF';
      } else if (discountType == 'flat') {
        label = '₹${(discountValue as num).toInt()} OFF';
      } else {
        label = discountValue.toString();
      }
    }

    final coupon = json['coupon_code']?.toString();
    final categoryName = json['category_name']?.toString();
    final minQty =
        (json['min_qty'] as num?)?.toInt() ?? (json['minQty'] as num?)?.toInt();
    final subtitle = json['subtitle']?.toString() ??
        [
          if (coupon != null && coupon.isNotEmpty) 'Code: $coupon',
          if (categoryName != null && categoryName.isNotEmpty)
            'On $categoryName',
          if (minQty != null && minQty > 1) 'Min qty $minQty',
        ].join(' · ');

    final validRaw = json['valid_until']?.toString() ??
        json['valid_till']?.toString() ??
        json['validUntil']?.toString() ??
        '';

    final rawTitle = json['title']?.toString() ?? '';

    return Offer(
      id: json['id']?.toString() ?? '',
      title: _sanitizeTitle(rawTitle),
      subtitle: subtitle,
      discountLabel: label.isEmpty ? 'OFFER' : label,
      validUntil: _parseApiDate(validRaw) ??
          DateTime.now().add(const Duration(days: 14)),
      gradientColors: colors,
      categoryId:
          json['category_id']?.toString() ?? json['categoryId']?.toString(),
      minQty: minQty,
      textColor: (json['text_color'] as num?)?.toInt(),
      featured: json['featured'] == true ||
          json['is_featured'] == true ||
          json['is_banner'] == true,
    );
  }

  static String _sanitizeTitle(String raw) {
    return raw
        .replaceFirst(RegExp(r'^DEMO\s*[—\-]\s*', caseSensitive: false), '')
        .trim();
  }

  static DateTime? _parseApiDate(String raw) {
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  bool get isActive => validUntil.isAfter(DateTime.now());

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
