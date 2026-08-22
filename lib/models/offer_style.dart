import 'package:flutter/material.dart';

import 'offer.dart';

/// Presentation helpers for offer cards (gradients) — not mock data.
class OfferStyle {
  OfferStyle._();

  static const _gradients = <List<int>>[
    [0xFF0B5C27, 0xFF12833B],
    [0xFFF5A623, 0xFFE8940A],
    [0xFF12833B, 0xFF1A9A48],
    [0xFF0B5C27, 0xFF0B5C27],
  ];

  static List<Color> colorsOf(Offer offer) {
    if (offer.gradientColors.isNotEmpty) {
      return offer.gradientColors.map(Color.new).toList();
    }
    final idx = (int.tryParse(offer.id) ?? offer.id.hashCode).abs() %
        _gradients.length;
    return _gradients[idx].map(Color.new).toList();
  }

  static Color textColorOf(Offer offer) =>
      Color(offer.textColor ?? 0xFFFFFFFF);
}
