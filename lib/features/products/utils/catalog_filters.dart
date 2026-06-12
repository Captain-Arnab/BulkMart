import 'package:urban_roots/features/products/models/Product.dart';

/// Keeps the best catalog row per product name and drops broken list-only items.
List<Product> filterCatalogProducts(List<Product> products) {
  final deduped = <String, Product>{};

  for (final product in products) {
    if (product.id.isEmpty || product.name.trim().isEmpty) continue;

    final key = product.name.trim().toLowerCase();
    final existing = deduped[key];
    if (existing == null || _catalogRank(product) > _catalogRank(existing)) {
      deduped[key] = product;
    }
  }

  final visible = deduped.values.toList();

  visible.sort((a, b) => _catalogRank(b).compareTo(_catalogRank(a)));
  return visible;
}

int _catalogRank(Product product) {
  var rank = 0;
  if (product.imageUrl.trim().isNotEmpty) rank += 100;
  if ((int.tryParse(product.stock) ?? 0) > 0) rank += 20;
  if (product.priceValue > 0) rank += 5;
  return rank;
}
