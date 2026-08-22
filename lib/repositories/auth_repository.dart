import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../core/storage/secure_storage_service.dart';
import '../models/business_type.dart';
import '../models/kyc_status.dart';
import '../models/user.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

class SendOtpResult {
  const SendOtpResult({this.devOtp});
  final String? devOtp;
}

/// Live auth repository — JWT session via secure storage.
class AuthRepository {
  AuthRepository({
    required SecureStorageService storage,
    required ApiClient apiClient,
  })  : _storage = storage,
        _apiClient = apiClient;

  final SecureStorageService _storage;
  final ApiClient _apiClient;

  /// Last OTP returned in DEV MODE (optional autofill). Null when SMS is live.
  String? lastDevOtp;

  Future<Result<SendOtpResult>> sendOtp({
    required String mobile,
    String businessName = '',
  }) async {
    try {
      if (mobile.trim().length < 10) {
        return const Failure(
          'Enter a valid 10-digit mobile number',
          code: 'VALIDATION_ERROR',
          fields: {'mobile': 'Enter a valid 10-digit mobile number'},
        );
      }
      if (businessName.trim().isNotEmpty) {
        await _storage.saveBusinessName(businessName.trim());
      }
      final response = await _apiClient.dio.post(
        ApiEndpoints.sendOtp,
        data: {'mobile': mobile.trim()},
      );
      return ApiEnvelope.parse(response, (data) {
        final map = data is Map ? Map<String, dynamic>.from(data) : null;
        final otp = map?['dev_otp']?.toString();
        lastDevOtp = otp;
        return SendOtpResult(devOtp: otp);
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> verifyOtp({
    required String mobile,
    required String otp,
    String businessName = '',
    bool persistSession = true,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'mobile': mobile.trim(), 'otp': otp.trim()},
      );
      final parsed = ApiEnvelope.parse(response, (data) {
        return Map<String, dynamic>.from(data as Map);
      });
      if (parsed is Failure<Map<String, dynamic>>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      final map = (parsed as Success<Map<String, dynamic>>).data;
      final user = await _persistAuthPayload(map, persistSession: persistSession);
      return Success(user);
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.emailLogin,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      final parsed = ApiEnvelope.parse(response, (data) {
        return Map<String, dynamic>.from(data as Map);
      });
      if (parsed is Failure<Map<String, dynamic>>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      final map = (parsed as Success<Map<String, dynamic>>).data;
      final user = await _persistAuthPayload(map, persistSession: true);
      return Success(user);
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  /// Updates email on profile. Public API does not yet expose password set.
  Future<Result<User>> setLoginPassword({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) {
      return const Failure(
        'Enter a valid email address',
        fields: {'email': 'Enter a valid email address'},
      );
    }
    if (password.length < 6) {
      return const Failure(
        'Password must be at least 6 characters',
        fields: {'password': 'Password must be at least 6 characters'},
      );
    }
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.profile,
        data: {'email': trimmed},
      );
      return ApiEnvelope.parse(response, (data) {
        final user = User.fromJson(Map<String, dynamic>.from(data as Map));
        final withFlag = user.copyWith(hasPassword: true, email: trimmed);
        _storage.saveUserJson(jsonEncode(withFlag.toJson()));
        return withFlag;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
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
    try {
      final apiType = _toApiBusinessType(businessTypeId, businessTypeLabel);
      final regResponse = await _apiClient.dio.post(
        ApiEndpoints.businessRegister,
        data: {
          'business_name': businessName.trim(),
          'owner_name': ownerName.trim(),
          'business_type': apiType,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (gstNumber != null && gstNumber.trim().isNotEmpty)
            'gst_number': gstNumber.trim(),
          if (fssaiNumber != null && fssaiNumber.trim().isNotEmpty)
            'fssai_number': fssaiNumber.trim(),
          if (panNumber != null && panNumber.trim().isNotEmpty)
            'pan_number': panNumber.trim(),
        },
      );
      final regResult = ApiEnvelope.parse(regResponse, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final customer = map['customer'];
        if (customer is Map) {
          return User.fromJson(Map<String, dynamic>.from(customer));
        }
        return User.fromJson(map);
      });
      if (regResult is Failure<User>) return regResult;

      final remoteDocs = <String, String>{};
      for (final entry in documents.entries) {
        final apiDocType = _toApiDocumentType(entry.key);
        if (apiDocType == null) continue;
        final path = entry.value;
        if (path.isEmpty || !File(path).existsSync()) continue;
        final form = FormData.fromMap({
          'document_type': apiDocType,
          'file': await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[\\/]')).last,
          ),
        });
        final docRes = await _apiClient.dio.post(
          ApiEndpoints.businessDocuments,
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );
        final parsed = ApiEnvelope.parse(docRes, (data) {
          final map = Map<String, dynamic>.from(data as Map);
          return map['file_url']?.toString() ?? path;
        });
        if (parsed is Success<String>) {
          remoteDocs[entry.key] = parsed.data;
        }
      }

      await _apiClient.dio.post(
        ApiEndpoints.addresses,
        data: {
          'label': 'Shop',
          'line1': shopAddress.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'pincode': pincode.trim(),
          if (landmark != null && landmark.trim().isNotEmpty)
            'landmark': landmark.trim(),
          if (geoLat != null) 'geo_lat': geoLat,
          if (geoLng != null) 'geo_lng': geoLng,
          'is_default': deliveryAddress.trim() == shopAddress.trim(),
        },
      );
      if (deliveryAddress.trim() != shopAddress.trim()) {
        await _apiClient.dio.post(
          ApiEndpoints.addresses,
          data: {
            'label': 'Delivery',
            'line1': deliveryAddress.trim(),
            'city': city.trim(),
            'state': state.trim(),
            'pincode': pincode.trim(),
            if (landmark != null && landmark.trim().isNotEmpty)
              'landmark': landmark.trim(),
            if (geoLat != null) 'geo_lat': geoLat,
            if (geoLng != null) 'geo_lng': geoLng,
            'is_default': true,
          },
        );
      }

      final profile = await fetchProfile();
      if (profile is Success<User>) {
        final composed =
            '${deliveryAddress.trim()}, ${city.trim()}, ${state.trim()} ${pincode.trim()}';
        final enriched = profile.data.copyWith(
          address: composed,
          shopAddress: shopAddress.trim(),
          deliveryAddress: deliveryAddress.trim(),
          city: city.trim(),
          state: state.trim(),
          landmark: landmark,
          pincode: pincode.trim(),
          geoLat: geoLat,
          geoLng: geoLng,
          businessTypeId: businessTypeId,
          businessType: businessTypeLabel,
          documents: remoteDocs.isNotEmpty ? remoteDocs : documents,
        );
        await _storage.saveUserJson(jsonEncode(enriched.toJson()));
        await _storage.saveBusinessName(enriched.businessName);
        return Success(enriched);
      }
      return profile;
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> updateProfile({required User user}) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.profile,
        data: {
          'business_name': user.businessName,
          'owner_name': user.ownerName ?? user.contactPerson,
          if (user.email != null) 'email': user.email,
          if (user.gstNumber != null) 'gst_number': user.gstNumber,
          if (user.fssaiNumber != null) 'fssai_number': user.fssaiNumber,
          if (user.panNumber != null) 'pan_number': user.panNumber,
        },
      );
      return ApiEnvelope.parse(response, (data) {
        final updated = User.fromJson(Map<String, dynamic>.from(data as Map));
        final merged = updated.copyWith(
          businessTypeId: user.businessTypeId ?? updated.businessTypeId,
          businessType: user.businessType ?? updated.businessType,
          documents:
              user.documents.isNotEmpty ? user.documents : updated.documents,
          shopAddress: user.shopAddress ?? updated.shopAddress,
          deliveryAddress: user.deliveryAddress ?? updated.deliveryAddress,
          city: user.city ?? updated.city,
          state: user.state ?? updated.state,
          pincode: user.pincode ?? updated.pincode,
          landmark: user.landmark ?? updated.landmark,
        );
        _storage.saveUserJson(jsonEncode(merged.toJson()));
        _storage.saveBusinessName(merged.businessName);
        return merged;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> uploadAvatar({required String localPath}) async {
    try {
      final form = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          localPath,
          filename: localPath.split(RegExp(r'[\\/]')).last,
        ),
      });
      final response = await _apiClient.dio.post(
        ApiEndpoints.profileAvatar,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ApiEnvelope.parse(response, (data) {
        final user = User.fromJson(Map<String, dynamic>.from(data as Map));
        _storage.saveUserJson(jsonEncode(user.toJson()));
        return user;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> removeAvatar() async {
    try {
      final response = await _apiClient.dio.delete(ApiEndpoints.profileAvatar);
      return ApiEnvelope.parse(response, (data) {
        final user = User.fromJson(Map<String, dynamic>.from(data as Map));
        _storage.saveUserJson(jsonEncode(user.toJson()));
        return user;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      return ApiEnvelope.parse(response, (data) {
        final user = User.fromJson(Map<String, dynamic>.from(data as Map));
        _storage.saveUserJson(jsonEncode(user.toJson()));
        _storage.saveBusinessName(user.businessName);
        return user;
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<User>> refreshVerificationStatus() async {
    try {
      final response =
          await _apiClient.dio.get(ApiEndpoints.businessVerificationStatus);
      final parsed = ApiEnvelope.parse(response, (data) {
        return Map<String, dynamic>.from(data as Map);
      });
      if (parsed is Failure<Map<String, dynamic>>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      final map = (parsed as Success<Map<String, dynamic>>).data;
      final current = await currentUser();
      final status = KycStatus.fromApi(map['kyc_status']?.toString());
      final reason = map['kyc_rejection_reason']?.toString();
      final docs = <String, String>{};
      final rawDocs = map['documents'];
      if (rawDocs is List) {
        for (final d in rawDocs) {
          if (d is Map) {
            final type = d['document_type']?.toString();
            final url = d['file_url']?.toString();
            if (type != null && url != null) docs[type] = url;
          }
        }
      }
      final updated = (current ??
              User(
                id: '',
                mobile: '',
                businessName: '',
                kycStatus: status,
              ))
          .copyWith(
        kycStatus: status,
        kycRejectionReason: reason,
        clearRejectionReason: reason == null || reason.isEmpty,
        documents: docs.isNotEmpty ? docs : null,
      );
      await _storage.saveUserJson(jsonEncode(updated.toJson()));
      return Success(updated);
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<Result<void>> resubmitKyc() async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.businessResubmit);
      final parsed = ApiEnvelope.parse(response, (_) => true);
      return parsed.when(
        success: (_) => const Success(null),
        failure: (message, {statusCode, code, fields}) => Failure(
          message,
          statusCode: statusCode,
          code: code,
          fields: fields,
        ),
      );
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  Future<User?> currentUser() async {
    final raw = await _storage.readUserJson();
    if (raw != null && raw.isNotEmpty) {
      try {
        return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    if (await _storage.hasToken()) {
      final result = await fetchProfile();
      return result.dataOrNull;
    }
    return null;
  }

  Future<bool> isLoggedIn() => _storage.hasToken();

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    try {
      await _apiClient.dio.post(
        ApiEndpoints.logout,
        data: {
          if (refresh != null && refresh.isNotEmpty) 'refresh_token': refresh,
        },
      );
    } catch (_) {
      // Always clear local session even if logout call fails.
    }
    await _storage.clearSession();
  }

  Future<User> _persistAuthPayload(
    Map<String, dynamic> map, {
    required bool persistSession,
  }) async {
    final access = map['access_token']?.toString() ?? '';
    final refresh = map['refresh_token']?.toString() ?? '';
    final customerRaw = map['customer'];
    final user = customerRaw is Map
        ? User.fromJson(Map<String, dynamic>.from(customerRaw))
        : const User(
            id: '',
            mobile: '',
            businessName: 'My Business',
            kycStatus: KycStatus.pending,
          );

    // Tokens are always stored after verify — registration needs JWT next.
    if (access.isNotEmpty) {
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      if (persistSession) {
        await _storage.saveUserJson(jsonEncode(user.toJson()));
        await _storage.saveBusinessName(user.businessName);
      }
    }
    return user;
  }

  static String _toApiBusinessType(String id, String label) {
    const map = {
      'retail_shop': 'retailer',
      'kirana_store': 'kirana',
      'supermarket': 'retailer',
      'hotel': 'hotel',
      'restaurant': 'restaurant',
      'catering_service': 'caterer',
      'vendor_reseller': 'wholesaler',
      'wholesaler': 'wholesaler',
      'other': 'other',
      'hostel': 'other',
      'hospital': 'other',
      'corporate_pantry': 'other',
      'juice_shop': 'other',
    };
    return map[id] ??
        (BusinessTypes.isOther(id) ? 'other' : label.toLowerCase());
  }

  static String? _toApiDocumentType(String flutterId) {
    const map = {
      'gstCertificate': 'gst_certificate',
      'fssaiLicense': 'fssai_license',
      'panCard': 'pan_card',
      'aadhaarCard': 'aadhaar_card',
      'shopRegistration': 'shop_establishment',
      'msmeCertificate': 'shop_establishment',
      'tradeLicense': 'trade_license',
      'shopFrontPhoto': 'business_photo',
      'visitingCard': 'business_photo',
    };
    return map[flutterId];
  }
}
