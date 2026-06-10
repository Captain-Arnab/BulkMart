import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

List<dynamic> extractList(dynamic data, {String key = 'data'}) {
  if (data is List) return data;
  if (data is Map) {
    final value = data[key];
    if (value is List) return value;
    if (value is Map) return [value];
  }
  return [];
}

List<Product> parseProducts(dynamic raw) {
  return extractList(raw)
      .whereType<Map>()
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<Category> parseCategories(dynamic raw) {
  return extractList(raw)
      .whereType<Map>()
      .map((e) {
        final m = Map<String, dynamic>.from(e);
        return Category(
          id: m['category_id']?.toString() ?? m['id']?.toString() ?? '',
          name: m['category_name']?.toString() ?? m['name']?.toString() ?? '',
          image: m['category_image']?.toString() ?? m['image']?.toString() ?? '',
          status: m['status']?.toString() ?? '0',
        );
      })
      .toList();
}

Map<String, dynamic> parseProfile(Map<String, dynamic> envelope) {
  final data = envelope['data'];
  if (data is Map<String, dynamic>) return data;
  return envelope;
}

String? extractAuthToken(Map<String, dynamic> data) {
  for (final key in ['token', 'access_token', 'api_token']) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
  }

  final inner = data['data'];
  if (inner is Map) {
    final nested = Map<String, dynamic>.from(inner);
    for (final key in ['token', 'access_token', 'api_token']) {
      final value = nested[key];
      if (value is String && value.isNotEmpty) return value;
    }
  }

  return null;
}

String? extractUserId(Map<String, dynamic> data) {
  for (final key in ['user_id', 'cust_id', 'id']) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }

  final inner = data['data'];
  if (inner is Map) {
    final nested = Map<String, dynamic>.from(inner);
    for (final key in ['user_id', 'cust_id', 'id']) {
      final value = nested[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
  }

  return null;
}
