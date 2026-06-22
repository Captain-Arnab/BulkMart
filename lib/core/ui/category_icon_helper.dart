import 'package:flutter/material.dart';

/// Corrects known typos from category API responses.
String formatCategoryDisplayName(String name) {
  return name
      .replaceAll(RegExp(r'diary', caseSensitive: false), 'DAIRY')
      .replaceAll(RegExp(r'miscellenous', caseSensitive: false), 'MISCELLANEOUS');
}

/// Maps category names to Material icons when API image is missing.
IconData categoryFallbackIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('baking')) return Icons.cake_outlined;
  if (lower.contains('fruit') || lower.contains('veg')) {
    return Icons.eco_outlined;
  }
  if (lower.contains('dairy') ||
      lower.contains('diary') ||
      lower.contains('milk')) {
    return Icons.local_drink_outlined;
  }
  if (lower.contains('spice')) return Icons.spa_outlined;
  if (lower.contains('snack')) return Icons.cookie_outlined;
  if (lower.contains('beverage') || lower.contains('drink')) {
    return Icons.local_cafe_outlined;
  }
  if (lower.contains('grain') || lower.contains('rice')) {
    return Icons.grain;
  }
  if (lower.contains('meat') || lower.contains('fish')) {
    return Icons.set_meal_outlined;
  }
  return Icons.local_grocery_store_outlined;
}

String? productOfferLabel(Map<String, dynamic> json) {
  final discount = json['discount'] ??
      json['discount_percent'] ??
      json['offer_percent'] ??
      json['offer'];
  if (discount != null) {
    final value = discount.toString().trim();
    if (value.isNotEmpty && value != '0') {
      return value.contains('%') ? value : '$value% OFF';
    }
  }

  final mrp = double.tryParse(
        json['mrp']?.toString() ??
            json['original_price']?.toString() ??
            json['old_price']?.toString() ??
            '0',
      ) ??
      0;
  final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0;
  if (mrp > price && price > 0) {
    final pct = ((mrp - price) / mrp * 100).round();
    if (pct > 0) return '$pct% OFF';
  }

  if (json['has_offer'] == true || json['is_offer'] == true) {
    return 'OFFER';
  }
  return null;
}
