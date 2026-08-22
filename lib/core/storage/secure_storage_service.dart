import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage for auth session keys.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenKey = 'auth_token'; // legacy alias → access
  static const _userJsonKey = 'user_json';
  static const _businessNameKey = 'business_name';

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// Prefer access token; fall back to legacy single-token key.
  Future<String?> readAccessToken() async {
    final access = await _storage.read(key: _accessTokenKey);
    if (access != null && access.isNotEmpty) return access;
    return _storage.read(key: _tokenKey);
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @Deprecated('Use saveAccessToken / saveTokens')
  Future<void> saveToken(String token) => saveAccessToken(token);

  @Deprecated('Use readAccessToken')
  Future<String?> readToken() => readAccessToken();

  Future<void> saveUserJson(String json) =>
      _storage.write(key: _userJsonKey, value: json);

  Future<String?> readUserJson() => _storage.read(key: _userJsonKey);

  Future<void> saveBusinessName(String name) =>
      _storage.write(key: _businessNameKey, value: name);

  Future<String?> readBusinessName() => _storage.read(key: _businessNameKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userJsonKey);
    await _storage.delete(key: _businessNameKey);
  }

  Future<bool> hasToken() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
