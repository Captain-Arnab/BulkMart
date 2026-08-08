import 'dart:collection';

import '../core/config/app_config.dart';
import '../services/api/api_client.dart';
import '../services/api/result.dart';

/// Session-scoped wishlist of product ids (demo).
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

  // ignore: unused_field — reserved for live wishlist endpoints
  final ApiClient _apiClient;

  @override
  Future<Result<List<String>>> getProductIds() async {
    throw UnimplementedError('ApiWishlistRepository.getProductIds');
  }

  @override
  Future<Result<List<String>>> toggle(String productId) async {
    throw UnimplementedError('ApiWishlistRepository.toggle');
  }

  @override
  Future<Result<List<String>>> remove(String productId) async {
    throw UnimplementedError('ApiWishlistRepository.remove');
  }

  @override
  Future<bool> contains(String productId) async {
    throw UnimplementedError('ApiWishlistRepository.contains');
  }
}
