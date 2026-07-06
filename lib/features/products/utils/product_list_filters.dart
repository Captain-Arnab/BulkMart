import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/utils/packing_filter_utils.dart';

List<Product> applyCatalogFilters({
  required List<Product> products,
  double minPrice = 0,
  double maxPrice = 2000,
  int? minGrams,
  int? maxGrams,
  String? packingType,
}) {
  final hasPackingFilter =
      packingType != null && packingType.trim().isNotEmpty;

  return products.where((product) {
    final priceMatch =
        product.priceValue >= minPrice && product.priceValue <= maxPrice;

    var gramsMatch = true;
    if (minGrams != null && maxGrams != null && minGrams > 0 && maxGrams > 0) {
      gramsMatch =
          product.gramsValue >= minGrams && product.gramsValue <= maxGrams;
    }

    var packingMatch = true;
    if (hasPackingFilter) {
      packingMatch = matchesPackingFilter(
        packingType,
        resolveProductPacking(product),
      );
    }

    return priceMatch && gramsMatch && packingMatch;
  }).toList();
}
