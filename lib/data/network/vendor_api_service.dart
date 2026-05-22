import 'package:dio/dio.dart';

/// Retrofit-style API stubs — wire implementations when backend is ready.
abstract class VendorApiService {
  Future<Response<Map<String, dynamic>>> login(Map<String, dynamic> body);
  Future<Response<Map<String, dynamic>>> getDashboard();
  Future<Response<List<dynamic>>> getProducts();
  Future<Response<Map<String, dynamic>>> getProduct(String id);
  Future<Response<Map<String, dynamic>>> createProduct(FormData data);
  Future<Response<Map<String, dynamic>>> updateProduct(String id, FormData data);
  Future<Response<void>> deleteProduct(String id);
  Future<Response<List<dynamic>>> getCategories();
  Future<Response<Map<String, dynamic>>> createCategory(Map<String, dynamic> body);
  Future<Response<Map<String, dynamic>>> updateCategory(String id, Map<String, dynamic> body);
  Future<Response<void>> deleteCategory(String id);
  Future<Response<List<dynamic>>> getOrders();
  Future<Response<Map<String, dynamic>>> getProfile();
  Future<Response<Map<String, dynamic>>> updateProfile(Map<String, dynamic> body);
  Future<Response<void>> logout();
}

class VendorApiServiceStub implements VendorApiService {
  VendorApiServiceStub(this.dio);
  final Dio dio;

  Never _notImplemented() => throw UnimplementedError('Wire VendorApiService when backend is ready');

  @override
  Future<Response<Map<String, dynamic>>> login(Map<String, dynamic> body) => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> getDashboard() => _notImplemented();

  @override
  Future<Response<List<dynamic>>> getProducts() => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> getProduct(String id) => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> createProduct(FormData data) => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> updateProduct(String id, FormData data) => _notImplemented();

  @override
  Future<Response<void>> deleteProduct(String id) => _notImplemented();

  @override
  Future<Response<List<dynamic>>> getCategories() => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> createCategory(Map<String, dynamic> body) => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> updateCategory(String id, Map<String, dynamic> body) => _notImplemented();

  @override
  Future<Response<void>> deleteCategory(String id) => _notImplemented();

  @override
  Future<Response<List<dynamic>>> getOrders() => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> getProfile() => _notImplemented();

  @override
  Future<Response<Map<String, dynamic>>> updateProfile(Map<String, dynamic> body) => _notImplemented();

  @override
  Future<Response<void>> logout() => _notImplemented();
}

/// OkHttp-style bearer interceptor for Dio.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);
  final Future<String?> Function() _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
