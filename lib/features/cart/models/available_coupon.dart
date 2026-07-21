class AvailableCoupon {
  const AvailableCoupon({
    required this.code,
    this.title = '',
    this.description = '',
    this.discountPercent = 0,
  });

  final String code;
  final String title;
  final String description;
  final int discountPercent;

  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (discountPercent > 0) return '$discountPercent% off';
    return code;
  }
}
