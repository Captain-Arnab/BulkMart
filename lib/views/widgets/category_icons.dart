import 'package:flutter/material.dart';

import '../../models/product.dart';

IconData categoryIconFor(String id) {
  return switch (id) {
    'grains' => Icons.rice_bowl_outlined,
    'oil' => Icons.oil_barrel_outlined,
    'dal' => Icons.soup_kitchen_outlined,
    'spices' => Icons.spa_outlined,
    'dry_fruits' => Icons.nightlife_outlined,
    'all' => Icons.grid_view_rounded,
    _ => Icons.category_outlined,
  };
}

String categoryShortLabel(ProductCategory cat) {
  if (cat.id == 'all') return 'All';
  return cat.name.split(' ').first;
}
