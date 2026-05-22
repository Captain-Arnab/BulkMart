import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

/// Persists auth token and role (Flutter equivalent of EncryptedSharedPreferences).
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _keyToken = 'auth_token';
  static const _keyRole = 'auth_role';
  static const _keyVendorId = 'vendor_id';
  static const _keyDisplayName = 'display_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> save({
    required String token,
    required AuthRole role,
    String? vendorId,
    String? displayName,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role.apiValue);
    if (vendorId != null) {
      await _storage.write(key: _keyVendorId, value: vendorId);
    } else {
      await _storage.delete(key: _keyVendorId);
    }
    if (displayName != null) {
      await _storage.write(key: _keyDisplayName, value: displayName);
    }
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<AuthRole?> getRole() async {
    final role = await _storage.read(key: _keyRole);
    return AuthRole.fromApi(role);
  }

  Future<String?> getVendorId() => _storage.read(key: _keyVendorId);

  Future<String?> getDisplayName() => _storage.read(key: _keyDisplayName);

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyVendorId);
    await _storage.delete(key: _keyDisplayName);
  }
}
