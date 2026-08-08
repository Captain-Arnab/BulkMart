import 'package:flutter/material.dart';

import '../../models/offer.dart';

class MockOffers {
  MockOffers._();

  static final List<Offer> all = [
    Offer(
      id: 'off_bulk_10',
      title: 'Flat 10% off on bulk\norders above ₹10,000',
      subtitle: 'Applies to all fruits & vegetables when cart total crosses ₹10,000.',
      discountLabel: '10% OFF',
      validUntil: DateTime.now().add(const Duration(days: 21)),
      gradientColors: const [0xFF0B5C27, 0xFF12833B],
      minQty: null,
      featured: true,
    ),
    Offer(
      id: 'off_greens',
      title: 'Fresh greens delivered\nin bulk this week',
      subtitle: 'Extra savings on green vegetables — MOQ applies per SKU.',
      discountLabel: 'SEASONAL',
      validUntil: DateTime.now().add(const Duration(days: 7)),
      gradientColors: const [0xFFF5A623, 0xFFE8940A],
      categoryId: 'green_vegetables',
      minQty: 10,
      textColor: 0xFF1E1F22,
      featured: true,
    ),
    Offer(
      id: 'off_free_del',
      title: 'Free delivery\nthis week',
      subtitle: 'No delivery fee on COD orders placed before Sunday.',
      discountLabel: 'FREE DELIVERY',
      validUntil: DateTime.now().add(const Duration(days: 5)),
      gradientColors: const [0xFF12833B, 0xFF1A9A48],
      featured: true,
    ),
    Offer(
      id: 'off_herbs',
      title: 'Herbs & leafy combo',
      subtitle: 'Buy 20+ units of herbs & leafy and unlock a coupon for next order.',
      discountLabel: 'COMBO',
      validUntil: DateTime.now().add(const Duration(days: 14)),
      gradientColors: const [0xFF0B5C27, 0xFF12833B],
      categoryId: 'herbs_leafy',
      minQty: 20,
      featured: false,
    ),
  ];

  static List<Color> colorsOf(Offer offer) =>
      offer.gradientColors.map((c) => Color(c)).toList();

  static Color textColorOf(Offer offer) =>
      Color(offer.textColor ?? 0xFFFFFFFF);
}
