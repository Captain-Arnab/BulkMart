import 'dart:convert';

import '../core/storage/secure_storage_service.dart';
import '../models/user.dart';
import '../services/api/result.dart';

/// Auth repository. Demo OTP until API is wired.
class AuthRepository {
  AuthRepository({required SecureStorageService storage}) : _storage = storage;

  final SecureStorageService _storage;

  static const demoOtp = '1234';

  Future<Result<void>> sendOtp({
    required String mobile,
    String businessName = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mobile.trim().length < 10) {
      return const Failure('Enter a valid 10-digit mobile number');
    }
    if (businessName.trim().isNotEmpty) {
      await _storage.saveBusinessName(businessName.trim());
    }
    return const Success(null);
  }

  Future<Result<User>> verifyOtp({
    required String mobile,
    required String otp,
    String businessName = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp.trim() != demoOtp) {
      return const Failure('Invalid OTP. Use 1234 for demo.');
    }

    final storedName = businessName.trim().isNotEmpty
        ? businessName.trim()
        : (await _storage.readBusinessName() ?? 'Bulk Buyer');

    final user = User(
      id: 'u_demo_1',
      mobile: mobile.trim(),
      businessName: storedName,
      address: '12, Wholesale Market Road, Bengaluru 560001',
      gstNumber: '29AAAAA0000A1Z5',
    );

    await _storage.saveToken('demo_jwt_token_${user.id}');
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    await _storage.saveBusinessName(user.businessName);

    return Success(user);
  }

  Future<Result<User>> completeRegistration({
    required String mobile,
    required String businessName,
    required String businessType,
    required String address,
    required String pincode,
    String? gstNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (businessName.trim().isEmpty) {
      return const Failure('Business name is required');
    }
    if (address.trim().isEmpty) {
      return const Failure('Delivery address is required');
    }
    if (pincode.trim().length != 6) {
      return const Failure('Enter a valid 6-digit pincode');
    }

    final user = User(
      id: 'u_demo_${DateTime.now().millisecondsSinceEpoch % 10000}',
      mobile: mobile.trim(),
      businessName: businessName.trim(),
      address: '${address.trim()}, $pincode',
      gstNumber: (gstNumber == null || gstNumber.trim().isEmpty) ? null : gstNumber.trim(),
    );

    await _storage.saveToken('demo_jwt_token_${user.id}');
    await _storage.saveUserJson(jsonEncode({
      ...user.toJson(),
      'business_type': businessType,
    }));
    await _storage.saveBusinessName(user.businessName);

    return Success(user);
  }

  Future<Result<User>> updateProfile({
    required User user,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
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
