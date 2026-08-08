import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/storage/secure_storage_service.dart';

typedef UnauthorizedCallback = void Function();

/// Single Dio client for the app. Auth token + 401 handling live here.
class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    String? baseUrl,
    this.onUnauthorized,
  }) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? kDefaultBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.clearSession();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// Placeholder — replace when staging/production URL is shared.
  static const String kDefaultBaseUrl = 'https://api.veggiicart.example/v1';

  final SecureStorageService _storage;
  UnauthorizedCallback? onUnauthorized;
  late final Dio _dio;

  Dio get dio => _dio;
}
