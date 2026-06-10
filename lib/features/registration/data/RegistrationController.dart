import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class RegistrationResult {
  const RegistrationResult._({
    required this.success,
    this.message,
    this.redirectToLogin = false,
  });

  final bool success;
  final String? message;
  final bool redirectToLogin;

  factory RegistrationResult.success() =>
      const RegistrationResult._(success: true, redirectToLogin: true);

  factory RegistrationResult.failure(
    String message, {
    bool redirectToLogin = false,
  }) =>
      RegistrationResult._(
        success: false,
        message: message,
        redirectToLogin: redirectToLogin,
      );
}

class RegistrationController extends GetxController {
  TextEditingController registerFirstNameController = TextEditingController();
  TextEditingController registerLastNameController = TextEditingController();
  TextEditingController registerPhoneNumberController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerConfirmPasswordController =
      TextEditingController();

  RxBool passwordVisible = false.obs;
  RxBool isLoading = false.obs;
  bool isRegistrationSuccess = false;
  String? lastError;

  final _api = UrbanRootsApi.instance;

  /// Returns validation error message, or null if valid.
  String? validateForm() {
    if (registerFirstNameController.text.isEmpty) {
      return 'Please enter first name';
    }
    if (registerLastNameController.text.isEmpty) {
      return 'Please enter last name';
    }
    if (registerPhoneNumberController.text.isEmpty) {
      return 'Please enter phone number';
    }
    if (registerEmailController.text.isEmpty) {
      return 'Please enter email';
    }
    if (registerPasswordController.text.isEmpty) {
      return 'Please enter password';
    }
    if (registerConfirmPasswordController.text.isEmpty) {
      return 'Please confirm password';
    }
    if (registerPasswordController.text !=
        registerConfirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<RegistrationResult> registerUser(
    String fName,
    String lName,
    String phoneNumber,
    String email,
    String password,
    String rePassword,
  ) async {
    isLoading(true);
    lastError = null;
    final result = await _api.auth.signup(
      name: fName,
      lname: lName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      rePassword: rePassword,
    );
    isLoading(false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      lastError = result.message;
      isRegistrationSuccess = false;
      return RegistrationResult.failure(
        result.message,
        redirectToLogin: _shouldOfferLogin(result.message),
      );
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final message = data['message'] as String?;
    if (!ApiStatus.isSuccess(data['status']) &&
        !ApiStatus.isSuccess(data['success']) &&
        message != null &&
        _looksLikeFailureMessage(message)) {
      lastError = message;
      isRegistrationSuccess = false;
      return RegistrationResult.failure(
        message,
        redirectToLogin: _shouldOfferLogin(message),
      );
    }

    isRegistrationSuccess = true;
    return RegistrationResult.success();
  }

  bool _shouldOfferLogin(String message) {
    final lower = message.toLowerCase();
    return lower.contains('already') ||
        lower.contains('exists') ||
        lower.contains('exist') ||
        lower.contains('login');
  }

  bool _looksLikeFailureMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('already') ||
        lower.contains('invalid') ||
        lower.contains('failed') ||
        lower.contains('error') ||
        lower.contains('duplicate');
  }

  void clearData() {
    registerFirstNameController.clear();
    registerLastNameController.clear();
    registerPhoneNumberController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  @override
  void onClose() {
    registerFirstNameController.dispose();
    registerLastNameController.dispose();
    registerPhoneNumberController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }
}
