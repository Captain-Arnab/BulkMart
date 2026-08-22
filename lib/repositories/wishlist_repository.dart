import 'dart:collection';

import '../core/config/app_config.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class WishlistRepository {
  factory WishlistRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) return MockWishlistRepository();
    return ApiWishlistRepository(apiClient: apiClient!);
  }

  Future<Result<List<String>>> getProductIds();
  Future<Result<List<String>>> toggle(String productId);
  Future<Result<List<String>>> remove(String productId);
  Future<bool> contains(String productId);
}

class MockWishlistRepository implements WishlistRepository {
  final LinkedHashSet<String> _ids = LinkedHashSet<String>();

  @override
  Future<Result<List<String>>> getProductIds() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Success(_ids.toList());
  }

  @override
  Future<Result<List<String>>> toggle(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    return Success(_ids.toList());
  }

  @override
  Future<Result<List<String>>> remove(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _ids.remove(productId);
    return Success(_ids.toList());
  }

  @override
  Future<bool> contains(String productId) async => _ids.contains(productId);
}

class ApiWishlistRepository implements WishlistRepository {
  ApiWishlistRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final LinkedHashSet<String> _cache = LinkedHashSet<String>();

  List<String> _idsFromData(dynamic data) {
    final items = data is Map && data['items'] is List
        ? data['items'] as List
        : const [];
    return items
        .map((e) {
          if (e is Map) {
            return e['product_id']?.toString() ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  @override
  Future<Result<List<String>>> getProductIds() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.wishlist);
      return ApiEnvelope.parse(response, (data) {
        final ids = _idsFromData(data);
        _cache
          ..clear()
          ..addAll(ids);
        return ids;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<String>>> toggle(String productId) async {
    if (_cache.isEmpty) {
      await getProductIds();
    }
    if (_cache.contains(productId)) {
      return remove(productId);
    }
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.wishlist,
        data: {
          'product_id': int.tryParse(productId) ?? productId,
        },
      );
      final parsed = ApiEnvelope.parse(response, (_) => null);
      if (parsed is Failure<Null>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      _cache.add(productId);
      return Success(_cache.toList());
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<String>>> remove(String productId) async {
    try {
      final response =
          await _apiClient.dio.delete(ApiEndpoints.wishlistItem(productId));
      final parsed = ApiEnvelope.parse(response, (_) => null);
      if (parsed is Failure<Null>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      _cache.remove(productId);
      return Success(_cache.toList());
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<bool> contains(String productId) async {
    if (_cache.isEmpty) {
      await getProductIds();
    }
    return _cache.contains(productId);
  }
}
