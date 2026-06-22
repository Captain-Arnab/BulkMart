class OfferModel {
  const OfferModel({
    required this.offerId,
    required this.title,
    required this.description,
    required this.couponCode,
    required this.discountPercent,
    required this.validTill,
    required this.imageUrl,
  });

  final int offerId;
  final String title;
  final String description;
  final String couponCode;
  final int discountPercent;
  final String validTill;
  final String imageUrl;

  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (discountPercent > 0) return '$discountPercent% Off';
    if (couponCode.isNotEmpty) return 'Exclusive Offer';
    return 'Special Offer';
  }

  String get displayDescription {
    if (description.trim().isNotEmpty) return description.trim();
    if (discountPercent > 0) {
      return 'Save $discountPercent% on your order. Copy the code and apply it at checkout.';
    }
    if (couponCode.isNotEmpty) {
      return 'Copy the coupon code and apply it at checkout to avail this offer.';
    }
    return '';
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      offerId: _int(json, ['offer_id', 'id', 'offerId']),
      title: _str(json, ['title', 'offer_title', 'name', 'offer_name']),
      description: _str(json, [
        'description',
        'offer_description',
        'desc',
        'details',
        'short_description',
      ]),
      couponCode: _str(json, ['coupon_code', 'code', 'promo_code', 'coupon']),
      discountPercent: _int(json, [
        'discount_percent',
        'discount_percentage',
        'discount',
        'percent_off',
      ]),
      validTill: _str(json, [
        'valid_till',
        'valid_until',
        'expiry_date',
        'expires_on',
        'valid_to',
      ]),
      imageUrl: _str(json, [
        'image_url',
        'image',
        'banner_url',
        'banner',
        'offer_image',
      ]),
    );
  }

  static String _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static int _int(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      if (raw == null) continue;
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }
}
