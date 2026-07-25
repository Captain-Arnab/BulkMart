import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool isLoading = false;
  String? error;
  User? user;

  String mobile = '';
  String businessName = '';

  void setMobile(String value) {
    mobile = value;
    error = null;
  }

  void setBusinessName(String value) {
    businessName = value;
    error = null;
  }

  Future<bool> bootstrapSession() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final loggedIn = await _authRepository.isLoggedIn();
      if (loggedIn) {
        user = await _authRepository.currentUser();
        isLoading = false;
        notifyListeners();
        return user != null;
      }
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.sendOtp(
      mobile: mobile,
      businessName: businessName,
    );

    return result.when(
      success: (_) {
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.verifyOtp(
      mobile: mobile,
      otp: otp,
      businessName: businessName,
    );

    return result.when(
      success: (u) {
        user = u;
        isLoading = false;
        notifyListeners();
        return true;
      },
      failure: (message, {statusCode}) {
        error = message;
        isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user = null;
    mobile = '';
    businessName = '';
    notifyListeners();
  }
}
