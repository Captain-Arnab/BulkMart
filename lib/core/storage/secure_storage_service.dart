import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage for auth session keys.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _tokenKey = 'auth_token';
  static const _userJsonKey = 'user_json';
  static const _businessNameKey = 'business_name';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserJson(String json) => _storage.write(key: _userJsonKey, value: json);

  Future<String?> readUserJson() => _storage.read(key: _userJsonKey);

  Future<void> saveBusinessName(String name) =>
      _storage.write(key: _businessNameKey, value: name);

  Future<String?> readBusinessName() => _storage.read(key: _businessNameKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userJsonKey);
    await _storage.delete(key: _businessNameKey);
  }

  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }
}
