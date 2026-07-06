import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/features/products/models/Product.dart';

const _packingJsonKeys = [
  'packing_type',
  'packingType',
  'packing',
  'package_type',
  'pd_packing_type',
  'pack_type',
  'packingtype',
];

/// Resolves packaging text from a catalog product row (list or detail).
String resolveProductPacking(Product product) {
  final direct = stripHtmlTags(product.packingType);
  if (direct.isNotEmpty) return direct;

  for (final key in _packingJsonKeys) {
    final raw = product.rawJson[key]?.toString() ?? '';
    final cleaned = stripHtmlTags(raw);
    if (cleaned.isNotEmpty) return cleaned;
  }

  return '';
}

/// Whether [productPacking] matches any of the comma-separated [filterPacking] values.
bool matchesPackingFilter(String filterPacking, String productPacking) {
  final product = _normalizePacking(productPacking);
  if (product.isEmpty) return false;

  final selected = filterPacking
      .split(',')
      .map(_normalizePacking)
      .where((e) => e.isNotEmpty)
      .toList();
  if (selected.isEmpty) return true;

  return selected.any((type) => _packingEquals(type, product));
}

String _normalizePacking(String value) {
  return stripHtmlTags(value)
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _packingEquals(String filter, String product) {
  if (filter.isEmpty) return true;
  if (product == filter) return true;
  if (product.contains(filter) || filter.contains(product)) return true;

  final filterTokens = filter.split(' ').where((t) => t.length > 2).toSet();
  final productTokens = product.split(' ').where((t) => t.length > 2).toSet();
  if (filterTokens.isNotEmpty &&
      filterTokens.every((token) => product.contains(token))) {
    return true;
  }

  for (final alias in _aliasesFor(filter)) {
    if (product.contains(alias) || alias.contains(product)) {
      return true;
    }
  }

  if (filterTokens.length == 1 && productTokens.contains(filterTokens.first)) {
    return true;
  }

  return false;
}

List<String> _aliasesFor(String filter) {
  if (filter.contains('unique') && filter.contains('pouch')) {
    return const ['unique pouch', 'unique'];
  }
  if (filter.contains('common') && filter.contains('pouch')) {
    return const ['common pouch', 'common'];
  }
  if (filter.contains('glass') || filter.contains('jar')) {
    return const ['glass jar', 'jar', 'glass'];
  }
  if (filter.contains('pouch')) {
    return const ['pouch'];
  }
  return const [];
}
