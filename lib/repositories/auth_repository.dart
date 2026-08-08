import 'dart:convert';

import '../core/storage/secure_storage_service.dart';
import '../models/business_type.dart';
import '../models/kyc_status.dart';
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
    bool persistSession = true,
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
      address: persistSession ? '12, Wholesale Market Road, Bengaluru 560001' : null,
      gstNumber: persistSession ? '29AAAAA0000A1Z5' : null,
      kycStatus: KycStatus.approved,
      businessTypeId: BusinessTypes.defaultId,
      businessType: BusinessTypes.byId(BusinessTypes.defaultId).label,
    );

    if (persistSession) {
      await _storage.saveToken('demo_jwt_token_${user.id}');
      await _storage.saveUserJson(jsonEncode(user.toJson()));
      await _storage.saveBusinessName(user.businessName);
    }

    return Success(user);
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Demo email+password login — any well-formed email + password length ≥ 6.
  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final trimmed = email.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) {
      return const Failure('Enter a valid email address');
    }
    if (password.length < 6) {
      return const Failure('Password must be at least 6 characters');
    }

    final existing = await currentUser();
    final User user;
    if (existing != null &&
        (existing.email?.toLowerCase() == trimmed || existing.hasPassword)) {
      user = existing.copyWith(
        email: trimmed,
        hasPassword: true,
        kycStatus: KycStatus.approved,
      );
    } else {
      user = User(
        id: 'u_email_${trimmed.hashCode.abs() % 100000}',
        mobile: existing?.mobile ?? '9000000000',
        businessName: existing?.businessName ?? 'Bulk Buyer',
        email: trimmed,
        address: '12, Wholesale Market Road, Bengaluru 560001',
        gstNumber: '29AAAAA0000A1Z5',
        kycStatus: KycStatus.approved,
        businessTypeId: BusinessTypes.defaultId,
        businessType: BusinessTypes.byId(BusinessTypes.defaultId).label,
        hasPassword: true,
      );
    }

    await _storage.saveToken('demo_jwt_token_${user.id}');
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    await _storage.saveBusinessName(user.businessName);
    return Success(user);
  }

  /// Opt-in email+password for returning users (Profile). Demo: no real hash stored.
  Future<Result<User>> setLoginPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = await currentUser();
    if (current == null) {
      return const Failure('Not signed in');
    }
    final trimmed = email.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) {
      return const Failure('Enter a valid email address');
    }
    if (password.length < 6) {
      return const Failure('Password must be at least 6 characters');
    }
    final updated = current.copyWith(email: trimmed, hasPassword: true);
    await _storage.saveUserJson(jsonEncode(updated.toJson()));
    return Success(updated);
  }

  Future<Result<User>> completeRegistration({
    required String mobile,
    required String businessName,
    required String businessTypeId,
    required String businessTypeLabel,
    required String ownerName,
    String? email,
    String? gstNumber,
    String? fssaiNumber,
    String? panNumber,
    required String shopAddress,
    required String deliveryAddress,
    required String city,
    required String state,
    String? landmark,
    required String pincode,
    double? geoLat,
    double? geoLng,
    Map<String, String> documents = const {},
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (businessName.trim().isEmpty) {
      return const Failure('Business name is required');
    }
    if (ownerName.trim().isEmpty) {
      return const Failure('Owner name is required');
    }
    if (shopAddress.trim().isEmpty) {
      return const Failure('Shop address is required');
    }
    if (deliveryAddress.trim().isEmpty) {
      return const Failure('Delivery address is required');
    }
    if (city.trim().isEmpty) {
      return const Failure('City is required');
    }
    if (state.trim().isEmpty) {
      return const Failure('State is required');
    }
    if (pincode.trim().length != 6) {
      return const Failure('Enter a valid 6-digit pincode');
    }
    if (!documents.containsKey('aadhaarCard') ||
        !documents.containsKey('shopFrontPhoto')) {
      return const Failure('Aadhaar Card and Shop Front Photo are required');
    }

    final composedAddress =
        '${deliveryAddress.trim()}, ${city.trim()}, ${state.trim()} ${pincode.trim()}';

    final user = User(
      id: 'u_demo_${DateTime.now().millisecondsSinceEpoch % 10000}',
      mobile: mobile.trim(),
      businessName: businessName.trim(),
      address: composedAddress,
      gstNumber:
          (gstNumber == null || gstNumber.trim().isEmpty) ? null : gstNumber.trim(),
      email: (email == null || email.trim().isEmpty) ? null : email.trim(),
      ownerName: ownerName.trim(),
      contactPerson: ownerName.trim(),
      businessType: businessTypeLabel,
      businessTypeId: businessTypeId,
      fssaiNumber:
          (fssaiNumber == null || fssaiNumber.trim().isEmpty) ? null : fssaiNumber.trim(),
      panNumber: (panNumber == null || panNumber.trim().isEmpty) ? null : panNumber.trim(),
      shopAddress: shopAddress.trim(),
      deliveryAddress: deliveryAddress.trim(),
      city: city.trim(),
      state: state.trim(),
      landmark: (landmark == null || landmark.trim().isEmpty) ? null : landmark.trim(),
      pincode: pincode.trim(),
      geoLat: geoLat,
      geoLng: geoLng,
      documents: documents,
      kycStatus: KycStatus.pending,
    );

    await _storage.saveToken('demo_jwt_token_${user.id}');
    await _storage.saveUserJson(jsonEncode(user.toJson()));
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

  Future<Result<User>> uploadAvatar({required String localPath}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final current = await currentUser();
    if (current == null) {
      return const Failure('Not signed in');
    }
    final updated = current.copyWith(avatarPath: localPath);
    await _storage.saveUserJson(jsonEncode(updated.toJson()));
    return Success(updated);
  }

  Future<Result<User>> removeAvatar() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final current = await currentUser();
    if (current == null) {
      return const Failure('Not signed in');
    }
    final updated = current.copyWith(clearAvatar: true);
    await _storage.saveUserJson(jsonEncode(updated.toJson()));
    return Success(updated);
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
