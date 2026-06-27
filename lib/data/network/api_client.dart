import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/config/api_config.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/vendor_request_gate.dart';

enum TokenMode { none, user, vendor, delivery }

/// When true, API failures must not clear session or redirect to login.
const String kSkipSessionClear = 'skipSessionClear';

/// Dio client for Urban Roots API — one instance per base URL.
class ApiClient {
  ApiClient._(
    String baseUrl, {
    this.isVendorClient = false,
    this.isDeliveryClient = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': ApiConfig.apiKey,
        },
        validateStatus: (status) => status != null && status < 600,
        // Plain text + manual JSON decode — PHP endpoints sometimes return HTML/errors that break Dio's JSON parser.
        responseType: ResponseType.plain,
      ),
    );
    // Reuse a single TLS connection per host. Opening several handshakes at
    // once (e.g. 5 vendor tabs loading together) made the server abort the
    // burst with TLSV1_ALERT_INTERNAL_ERROR; serialising over one kept-alive
    // connection does a single handshake and reuses it for the rest.
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => SharedHttpClient.instance.client,
    );
    _dio.interceptors.add(_UrbanRootsInterceptor(this));
    if (kDebugMode) {
      // NOTE: never enable `responseBody`/`responseHeader` here. Endpoints like
      // product-view return very large HTML payloads, and LogInterceptor prints
      // the body line-by-line on the UI isolate — dumping several of those (e.g.
      // cart enrichment fetching every item) freezes the app / triggers an ANR.
      // Errors are already logged in a truncated form via `_logApiError`.
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      );
    }
  }

  /// User API — https://urbunroots.com/api/user
  static final ApiClient user = ApiClient._(ApiConfig.userBaseUrl);

  /// Vendor API — https://urbunroots.com/api/vendor
  static final ApiClient vendor =
      ApiClient._(ApiConfig.vendorBaseUrl, isVendorClient: true);

  /// Site API — https://urbunroots.com/api (offers, etc.)
  static final ApiClient site = ApiClient._(ApiConfig.apiBaseUrl);

  /// Admin API — https://urbunroots.com/api/admin (no auth token).
  static final ApiClient admin = ApiClient._(ApiConfig.adminBaseUrl);

  /// Delivery boy API — https://urbunroots.com/delivery_boy_api
  static final ApiClient delivery =
      ApiClient._(ApiConfig.deliveryBaseUrl, isDeliveryClient: true);

  /// Back-compat alias for user client.
  static ApiClient get instance => user;

  final bool isVendorClient;
  final bool isDeliveryClient;

  late final Dio _dio;

  VoidCallback? onUnauthorized;

  Dio get dio => _dio;

  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    TokenMode token = TokenMode.user,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
  }) =>
      _request(
        () => _dio.get(
          path,
          queryParameters: queryParameters,
          options: _options(token, extraHeaders),
        ),
        authenticated: token != TokenMode.none,
      );

  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    TokenMode token = TokenMode.user,
    Map<String, String>? extraHeaders,
    bool skipSessionClear = false,
  }) =>
      _request(
        () => _dio.post(
          path,
          data: body,
          options:
              _options(token, extraHeaders, skipSessionClear: skipSessionClear),
        ),
        authenticated: token != TokenMode.none,
        skipSessionClear: skipSessionClear,
      );

  Future<ApiResult<Map<String, dynamic>>> put(
    String path, {
    Object? body,
    TokenMode token = TokenMode.user,
    Map<String, String>? extraHeaders,
  }) =>
      _request(
        () => _dio.put(
          path,
          data: body,
          options: _options(token, extraHeaders),
        ),
        authenticated: token != TokenMode.none,
      );

  Future<ApiResult<Map<String, dynamic>>> delete(
    String path, {
    Object? body,
    TokenMode token = TokenMode.user,
    Map<String, String>? extraHeaders,
  }) =>
      _request(
        () => _dio.delete(
          path,
          data: body,
          options: _options(token, extraHeaders),
        ),
        authenticated: token != TokenMode.none,
      );

  Future<ApiResult<String>> getPlain(
    String path, {
    TokenMode token = TokenMode.none,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<String>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.plain,
          extra: {'tokenMode': token},
        ),
      );
      return ApiSuccess(response.data ?? '');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && token != TokenMode.none) {
        await _handleUnauthorized();
      }
      return ApiFailure(
        _dioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Options _options(
    TokenMode token,
    Map<String, String>? extraHeaders, {
    bool skipSessionClear = false,
  }) {
    return Options(
      headers: extraHeaders,
      extra: {
        'tokenMode': token,
        if (skipSessionClear) kSkipSessionClear: true,
      },
    );
  }

  /// Re-attempt idempotent (GET) calls that fail with a transient network
  /// error — a dropped/reset connection or timeout. Non-GET calls and
  /// server-level (badResponse) failures are never retried.
  static const int _maxTransientRetries = 2;

  bool _isTransient(DioException e) {
    if (e.error is HandshakeException) return false;
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        return true;
      default:
        return false;
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _request(
    Future<Response<dynamic>> Function() call, {
    required bool authenticated,
    bool skipSessionClear = false,
  }) {
    Future<ApiResult<Map<String, dynamic>>> execute() => _requestWithRetry(
          call,
          authenticated: authenticated,
          skipSessionClear: skipSessionClear,
        );
    if (isVendorClient) {
      return VendorRequestGate.instance.run(execute);
    }
    return execute();
  }

  Future<ApiResult<Map<String, dynamic>>> _requestWithRetry(
    Future<Response<dynamic>> Function() call, {
    required bool authenticated,
    bool skipSessionClear = false,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _attempt(
          call,
          authenticated: authenticated,
          skipSessionClear: skipSessionClear,
        );
      } on DioException catch (e) {
        final isGet = e.requestOptions.method.toUpperCase() == 'GET';
        if (isGet && _isTransient(e) && attempt < _maxTransientRetries) {
          attempt++;
          if (kDebugMode) {
            debugPrint(
              '[ApiClient] Transient ${e.type} on ${e.requestOptions.uri} — '
              'retry $attempt/$_maxTransientRetries',
            );
          }
          await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }
        final skipClear = skipSessionClear ||
            (e.requestOptions.extra[kSkipSessionClear] == true);
        if (e.response?.statusCode == 401 && authenticated && !skipClear) {
          await _handleUnauthorized();
        }
        return ApiFailure(
          _dioErrorMessage(e),
          statusCode: e.response?.statusCode,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[ApiClient] Unexpected error: $e');
        return ApiFailure(e.toString());
      }
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _attempt(
    Future<Response<dynamic>> Function() call, {
    required bool authenticated,
    bool skipSessionClear = false,
  }) async {
    final response = await call();
    final statusCode = response.statusCode;
    final requestUri = response.requestOptions.uri.toString();
    final data = _parseResponseBody(
      response.data,
      requestUri: requestUri,
    );

    if (data == null) {
      return ApiFailure(
        'Empty response from server',
        statusCode: statusCode,
      );
    }

    if (data['_nonJsonResponse'] == true) {
      return ApiFailure(
        _extractMessage(data) ?? 'Server error: non-JSON response received',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 400) {
      final message =
          _extractMessage(data) ?? 'Server error (HTTP $statusCode)';
      if (authenticated &&
          !skipSessionClear &&
          (statusCode == 401 || _isSessionExpired(message))) {
        await _handleUnauthorized();
      }
      return ApiFailure(message, statusCode: statusCode);
    }

    final apiSuccess = ApiStatus.fromMap(data);
    if (apiSuccess == false ||
        (apiSuccess == null && _messageIndicatesFailure(data))) {
      final message = _extractMessage(data) ?? 'Request failed';
      if (authenticated &&
          !skipSessionClear &&
          (statusCode == 401 || _isSessionExpired(message))) {
        await _handleUnauthorized();
      }
      return ApiFailure(message, statusCode: statusCode);
    }

    return ApiSuccess(data);
  }

  bool _looksLikeHtml(String raw) {
    final trimmed = raw.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return false;
    return trimmed.startsWith('<!') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<');
  }

  String? _extractEmbeddedJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end <= start) return null;
    return raw.substring(start, end + 1);
  }

  void _logApiError(String? requestUri, String rawBody) {
    final tag = isVendorClient ? '[VENDOR_API_ERROR]' : '[API_ERROR]';
    final preview =
        rawBody.length > 500 ? '${rawBody.substring(0, 500)}...' : rawBody;
    debugPrint('$tag uri=${requestUri ?? 'unknown'} body=$preview');
  }

  Map<String, dynamic>? _parseResponseBody(
    dynamic raw, {
    String? requestUri,
  }) {
    if (raw == null) return null;

    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      if (_looksLikeHtml(trimmed)) {
        _logApiError(requestUri, trimmed);
        return {
          'status': false,
          '_nonJsonResponse': true,
          'message': 'Server error: non-JSON response received',
        };
      }

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        final embedded = _extractEmbeddedJson(trimmed);
        if (embedded != null) {
          try {
            final decoded = jsonDecode(embedded);
            if (decoded is Map) {
              return Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
        }
        _logApiError(requestUri, trimmed);
        if (kDebugMode) {
          debugPrint(
            '[ApiClient] Non-JSON response: '
            '${trimmed.length > 300 ? '${trimmed.substring(0, 300)}...' : trimmed}',
          );
        }
        return {
          'status': false,
          '_nonJsonResponse': true,
          'message': 'Server error: non-JSON response received',
        };
      }
    }

    return null;
  }

  bool _isSessionExpired(String message) {
    final lower = message.toLowerCase();
    const patterns = [
      'unauthorized',
      'session expired',
      'session invalid',
      'invalid token',
      'token expired',
      'token has expired',
      'not authenticated',
      'login again',
      'please log in',
      'please login',
      'authentication failed',
      'auth failed',
    ];
    return patterns.any(lower.contains);
  }

  Future<void> _handleUnauthorized() async {
    if (isVendorClient) {
      await AuthSession.instance.clearVendorSession();
    } else if (isDeliveryClient) {
      await AuthSession.instance.clearDeliveryToken();
    } else {
      await AuthSession.instance.clear();
    }
    onUnauthorized?.call();
  }

  String? _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return null;
  }

  bool _messageIndicatesFailure(Map<String, dynamic> data) {
    final message = _extractMessage(data)?.toLowerCase() ?? '';
    if (message.isEmpty) return false;
    const failureHints = [
      'already registered',
      'already exists',
      'already exist',
      'duplicate',
      'invalid',
      'not found',
      'failed',
      'error',
      'required',
      'incorrect',
      'wrong',
    ];
    return failureHints.any(message.contains);
  }

  String _dioErrorMessage(DioException e) {
    final parsed = _parseResponseBody(
      e.response?.data,
      requestUri: e.requestOptions.uri.toString(),
    );
    if (parsed != null) {
      final msg = _extractMessage(parsed);
      if (msg != null) return msg;
    }

    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'Could not reach the server (${e.requestOptions.uri.host}). '
            'The app has internet permission — check emulator Wi‑Fi or try email login.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) {
          return 'Unauthorized request. Please contact support if this continues.';
        }
        if (code != null && code >= 500) {
          return 'Server error ($code). Please try again later.';
        }
        return e.message ?? 'Server returned an error';
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      case DioExceptionType.unknown:
        if (e.error is HandshakeException) {
          return 'Secure connection failed. Please wait a moment and tap Retry, '
              'or try on a physical device if you are on an emulator.';
        }
        // Usually a dropped/reset connection (server closed the socket, e.g.
        // a PHP fatal mid-output) or transient emulator network loss. Surface
        // the underlying cause so it is actionable instead of generic.
        final cause = e.error?.toString() ?? e.message;
        if (kDebugMode) {
          debugPrint(
            '[ApiClient] Unknown DioException: error=${e.error}, '
            'message=${e.message}, uri=${e.requestOptions.uri}',
          );
        }
        if (cause != null && cause.isNotEmpty) {
          return 'Could not complete the request ($cause). Please try again.';
        }
        return 'Could not reach the server. Please check your connection and try again.';
    }
  }
}

class _UrbanRootsInterceptor extends Interceptor {
  _UrbanRootsInterceptor(this._client);
  final ApiClient _client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Let Dio set the multipart boundary for file uploads; forcing JSON here
    // would corrupt the request body.
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['x-api-key'] = ApiConfig.apiKey;

    final tokenMode =
        options.extra['tokenMode'] as TokenMode? ?? TokenMode.user;

    if (tokenMode != TokenMode.none) {
      final String? token;
      switch (tokenMode) {
        case TokenMode.vendor:
          token = await AuthSession.instance.getVendorToken();
        case TokenMode.delivery:
          token = await AuthSession.instance.getDeliveryToken();
        case TokenMode.user:
        case TokenMode.none:
          token = await AuthSession.instance.getUserToken();
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final skipClear = err.requestOptions.extra[kSkipSessionClear] == true;
      if (skipClear) {
        handler.next(err);
        return;
      }
      final tokenMode =
          err.requestOptions.extra['tokenMode'] as TokenMode? ?? TokenMode.user;
      if (tokenMode != TokenMode.none) {
        _client._handleUnauthorized();
      }
    }
    handler.next(err);
  }
}

/// Cart requests require X-Platform: app.
const Map<String, String> cartPlatformHeader = {'X-Platform': 'app'};
