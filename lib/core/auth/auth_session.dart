import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

/// Persists auth tokens in encrypted SharedPreferences (FlutterSecureStorage).
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _keyUserToken = 'api_token';
  static const _keyVendorToken = 'vendor_api_token';
  static const _keyRole = 'auth_role';
  static const _keyVendorId = 'vendor_id';
  static const _keyUserId = 'user_id';
  static const _keyDisplayName = 'display_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveUserSession({
    required String token,
    String? userId,
    String? displayName,
  }) async {
    await _storage.write(key: _keyUserToken, value: token);
    await _storage.write(key: _keyRole, value: AuthRole.user.apiValue);
    await _storage.delete(key: _keyVendorToken);
    await _storage.delete(key: _keyVendorId);
    if (userId != null) {
      await _storage.write(key: _keyUserId, value: userId);
    }
    if (displayName != null) {
      await _storage.write(key: _keyDisplayName, value: displayName);
    }
  }

  Future<void> saveVendorSession({
    required String token,
    required String vendorId,
    String? displayName,
  }) async {
    await _storage.write(key: _keyVendorToken, value: token);
    await _storage.write(key: _keyRole, value: AuthRole.vendor.apiValue);
    await _storage.write(key: _keyVendorId, value: vendorId);
    if (displayName != null) {
      await _storage.write(key: _keyDisplayName, value: displayName);
    }
  }

  /// Legacy helper — routes to user or vendor save based on role.
  Future<void> save({
    required String token,
    required AuthRole role,
    String? vendorId,
    String? userId,
    String? displayName,
  }) async {
    if (role == AuthRole.vendor) {
      await saveVendorSession(
        token: token,
        vendorId: vendorId ?? '',
        displayName: displayName,
      );
    } else {
      await saveUserSession(
        token: token,
        userId: userId,
        displayName: displayName,
      );
    }
  }

  Future<String?> getUserToken() => _storage.read(key: _keyUserToken);

  Future<String?> getVendorToken() => _storage.read(key: _keyVendorToken);

  /// Active session token based on stored role.
  Future<String?> getToken() async {
    final role = await getRole();
    if (role == AuthRole.vendor) return getVendorToken();
    return getUserToken();
  }

  Future<AuthRole?> getRole() async {
    final role = await _storage.read(key: _keyRole);
    return AuthRole.fromApi(role);
  }

  Future<String?> getVendorId() => _storage.read(key: _keyVendorId);

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  Future<String?> getDisplayName() => _storage.read(key: _keyDisplayName);

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearUserToken() => _storage.delete(key: _keyUserToken);

  /// Clears only vendor session keys — does not touch user token.
  Future<void> clearVendorSession() async {
    await _storage.delete(key: _keyVendorToken);
    await _storage.delete(key: _keyVendorId);
    final role = await getRole();
    if (role == AuthRole.vendor) {
      await _storage.delete(key: _keyRole);
      await _storage.delete(key: _keyDisplayName);
    }
  }

  Future<bool> hasVendorSession() async {
    final token = await getVendorToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyUserToken);
    await _storage.delete(key: _keyVendorToken);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyVendorId);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyDisplayName);
  }
}
