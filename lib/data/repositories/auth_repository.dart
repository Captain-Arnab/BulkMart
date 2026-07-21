import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/models/login_response.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

/// Auth repository backed by Urban Roots API contract.
abstract class AuthRepository {
  Future<ApiResult<LoginResponse>> login({
    required String identifier,
    required String password,
    AuthRole? selectedRole,
  });

  Future<ApiResult<void>> logout();

  Future<ApiResult<void>> forgotPasswordSendOtp(String email);

  Future<ApiResult<void>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  });

  Future<ApiResult<void>> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  });
}

class LiveAuthRepository implements AuthRepository {
  LiveAuthRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String identifier,
    required String password,
    AuthRole? selectedRole,
  }) async {
    final role = selectedRole ?? AuthRole.user;

    if (role == AuthRole.vendor) {
      final result = await _api.vendorAuth.login(
        email: identifier,
        password: password,
      );
      return _mapVendorLogin(result);
    }

    final result = await _api.auth.login(
      login: identifier,
      password: password,
    );
    return _mapUserLogin(result);
  }

  ApiResult<LoginResponse> _mapUserLogin(
    ApiResult<Map<String, dynamic>> result,
  ) {
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final token = extractAuthToken(data) ?? '';
    final userData = data['data'];
    String? name;
    String? userId;
    if (userData is Map<String, dynamic>) {
      name = userData['name'] as String? ?? userData['cust_fname'] as String?;
      userId = userData['cust_id']?.toString() ?? userData['id']?.toString();
    }
    return ApiSuccess(
      LoginResponse(
        token: token,
        role: AuthRole.user,
        name: name,
        userId: userId,
      ),
    );
  }

  ApiResult<LoginResponse> _mapVendorLogin(
    ApiResult<Map<String, dynamic>> result,
  ) {
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      return const ApiFailure('Invalid vendor login response');
    }
    return ApiSuccess(
      LoginResponse(
        token: inner['token'] as String? ?? '',
        role: AuthRole.vendor,
        vendorId: inner['vendor_id']?.toString(),
      ),
    );
  }

  @override
  Future<ApiResult<void>> logout() async {
    final result = await _api.auth.logout();
    await AuthSession.instance.clear();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message);
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> forgotPasswordSendOtp(String email) =>
      _mapForgotPassword(
        _api.auth.forgotPassword(step: 'send_otp', email: email),
      );

  @override
  Future<ApiResult<void>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) =>
      _mapForgotPassword(
        _api.auth.forgotPassword(
          step: 'verify_otp',
          email: email,
          otp: otp,
        ),
      );

  @override
  Future<ApiResult<void>> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      _mapForgotPassword(
        _api.auth.forgotPassword(
          step: 'reset_password',
          email: email,
          otp: otp,
          newPassword: newPassword,
        ),
      );

  Future<ApiResult<void>> _mapForgotPassword(
    Future<ApiResult<Map<String, dynamic>>> call,
  ) async {
    final result = await call;
    if (result is ApiFailure<Map<String, dynamic>>) {
      return ApiFailure(result.message, statusCode: result.statusCode);
    }
    return const ApiSuccess(null);
  }
}

/// Retained for offline / demo flows.
class MockAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<LoginResponse>> login({
    required String identifier,
    required String password,
    AuthRole? selectedRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final role = selectedRole ?? AuthRole.user;
    if (role == AuthRole.vendor) {
      return const ApiSuccess(
        LoginResponse(
          token: 'mock_vendor_jwt_token',
          role: AuthRole.vendor,
          vendorId: 'VND001',
          name: 'Urban Roots Vendor',
        ),
      );
    }
    return const ApiSuccess(
      LoginResponse(
        token: 'mock_user_jwt_token',
        role: AuthRole.user,
        name: 'Urban Roots Customer',
      ),
    );
  }

  @override
  Future<ApiResult<void>> logout() async {
    await AuthSession.instance.clear();
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> forgotPasswordSendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.trim().isEmpty) {
      return const ApiFailure('Email is required');
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (otp.trim().length < 4) {
      return const ApiFailure('Invalid or expired OTP');
    }
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (newPassword.length < 6) {
      return const ApiFailure('Password must be at least 6 characters');
    }
    return const ApiSuccess(null);
  }
}
