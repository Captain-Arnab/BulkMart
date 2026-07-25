import 'dart:convert';

import '../core/storage/secure_storage_service.dart';
import '../models/user.dart';
import '../services/api/result.dart';

/// Auth repository. Uses secure storage + dummy OTP until API is wired.
class AuthRepository {
  AuthRepository({required SecureStorageService storage}) : _storage = storage;

  final SecureStorageService _storage;

  /// Demo OTP accepted for client walkthrough. Replace with API verify.
  static const demoOtp = '1234';

  Future<Result<void>> sendOtp({
    required String mobile,
    required String businessName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mobile.trim().length < 10) {
      return const Failure('Enter a valid 10-digit mobile number');
    }
    if (businessName.trim().isEmpty) {
      return const Failure('Business name is required');
    }
    await _storage.saveBusinessName(businessName.trim());
    // Real call: POST ApiEndpoints.sendOtp
    return const Success(null);
  }

  Future<Result<User>> verifyOtp({
    required String mobile,
    required String otp,
    required String businessName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (otp.trim() != demoOtp) {
      return const Failure('Invalid OTP. Use 1234 for demo.');
    }

    final user = User(
      id: 'u_demo_1',
      mobile: mobile.trim(),
      businessName: businessName.trim(),
      address: '12, Wholesale Market Road, Bengaluru 560001',
      gstNumber: '29AAAAA0000A1Z5',
    );

    // Real call: POST ApiEndpoints.verifyOtp → token + user
    await _storage.saveToken('demo_jwt_token_${user.id}');
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    await _storage.saveBusinessName(user.businessName);

    return Success(user);
  }

  Future<User?> currentUser() async {
    final raw = await _storage.readUserJson();
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() => _storage.hasToken();

  Future<void> logout() => _storage.clearSession();
}
