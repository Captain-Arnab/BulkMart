import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> signup({
    required String name,
    required String lname,
    required String email,
    required String phoneNumber,
    required String password,
    required String rePassword,
  }) =>
      _client.post(
        APIClass.userSignup,
        token: TokenMode.none,
        body: {
          'name': name,
          'lname': lname,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          're_password': rePassword,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> login({
    required String login,
    required String password,
  }) async {
    final result = await _client.post(
      APIClass.userLogin,
      token: TokenMode.none,
      body: {'login': login, 'password': password},
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final token = extractAuthToken(result.data);
      if (token != null && token.isNotEmpty) {
        await AuthSession.instance.saveUserSession(
          token: token,
          userId: extractUserId(result.data),
        );
      }
    }
    return result;
  }

  Future<ApiResult<Map<String, dynamic>>> logout() async {
    final result = await _client.post(APIClass.userLogout);
    // Contract: clear local token on any response.
    await AuthSession.instance.clearUserToken();
    return result;
  }

  Future<ApiResult<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _client.post(
        APIClass.changePassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> otpLogin({
    required String phone,
    required String otp,
  }) async {
    final result = await _client.post(
      APIClass.otpLogin,
      token: TokenMode.none,
      body: {'phone': phone, 'otp': otp},
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final token = extractAuthToken(result.data);
      if (token != null && token.isNotEmpty) {
        await AuthSession.instance.saveUserSession(
          token: token,
          userId: extractUserId(result.data),
        );
      }
    }
    return result;
  }

  Future<ApiResult<Map<String, dynamic>>> sendLoginOtp({
    required String phone,
  }) {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    return _client.post(
      APIClass.sendLoginOtp,
      token: TokenMode.none,
      body: {'phone': normalized},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> socialLogin({
    required String provider,
    required String idToken,
  }) async {
    final result = await _client.post(
      APIClass.socialLogin,
      token: TokenMode.none,
      body: {'provider': provider, 'id_token': idToken},
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final token = extractAuthToken(result.data);
      if (token != null && token.isNotEmpty) {
        await AuthSession.instance.saveUserSession(
          token: token,
          userId: extractUserId(result.data),
        );
      }
    }
    return result;
  }
}
