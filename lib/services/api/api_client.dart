import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/secure_storage_service.dart';
import 'api_endpoints.dart';

typedef UnauthorizedCallback = void Function();
typedef AccountBlockedCallback = void Function(String message);

/// Single Dio client for the app. JWT attach + refresh + 403 live here.
class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    String? baseUrl,
    this.onUnauthorized,
    this.onAccountBlocked,
  }) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
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
          final path = options.path;
          if (!ApiEndpoints.isPublicPath(path)) {
            final token = await _storage.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] =
                  '${AppConfig.kAuthHeaderPrefix}$token';
            }
          } else {
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final status = response?.statusCode;
          final data = response?.data;
          String? code;
          String? message;
          if (data is Map) {
            final err = data['error'];
            if (err is Map) {
              code = err['code']?.toString();
              message = err['message']?.toString();
            }
          }

          // Blocked account — do NOT refresh; force logout.
          if (status == 403 && code == 'FORBIDDEN') {
            await _storage.clearSession();
            onAccountBlocked?.call(
              message ?? 'Your account has been blocked. Contact support.',
            );
            onUnauthorized?.call();
            return handler.next(error);
          }

          final path = error.requestOptions.path;
          final isRefreshCall = path.contains(ApiEndpoints.refreshToken);
          final alreadyRetried =
              error.requestOptions.extra['auth_retry'] == true;

          if (status == 401 &&
              code == 'UNAUTHORIZED' &&
              !isRefreshCall &&
              !alreadyRetried &&
              !ApiEndpoints.isPublicPath(path)) {
            try {
              final refreshed = await _refreshTokens();
              if (refreshed) {
                final opts = error.requestOptions;
                opts.extra['auth_retry'] = true;
                final token = await _storage.readAccessToken();
                if (token != null) {
                  opts.headers['Authorization'] =
                      '${AppConfig.kAuthHeaderPrefix}$token';
                }
                final clone = await _dio.fetch(opts);
                return handler.resolve(clone);
              }
            } catch (_) {
              // fall through to logout
            }
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

  final SecureStorageService _storage;
  UnauthorizedCallback? onUnauthorized;
  AccountBlockedCallback? onAccountBlocked;
  late final Dio _dio;
  Completer<bool>? _refreshCompleter;

  Dio get dio => _dio;

  Future<bool> _refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }

      // Use a bare Dio call so we don't recurse through the auth interceptor.
      final bare = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await bare.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refresh},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        completer.complete(false);
        return false;
      }
      final data = body['data'];
      if (data is! Map) {
        completer.complete(false);
        return false;
      }
      final access = data['access_token']?.toString();
      final newRefresh = data['refresh_token']?.toString();
      if (access == null ||
          access.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        completer.complete(false);
        return false;
      }
      await _storage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh,
      );
      completer.complete(true);
      return true;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
