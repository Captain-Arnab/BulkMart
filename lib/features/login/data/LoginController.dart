import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool passwordVisible = false.obs;
  RxBool isLoading = false.obs;
  Rx<AuthRole> selectedRole = AuthRole.user.obs;
  /// Set once after a successful auth API response. Listeners should navigate
  /// away / dismiss login UI exactly when this flips to true.
  final RxBool isLoginSuccess = false.obs;
  String userId = "USR001";
  String userName = "Arnab Som";
  String userEmail = "arnab@urbanroots.com";
  String userMobile = "+91 97385 50132";

  void markLoginSuccess() {
    isLoginSuccess.value = true;
  }

  Future<void> userLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    isLoading(true);

    await Future.delayed(const Duration(milliseconds: 800));

    markLoginSuccess();
    isLoading(false);
  }

  Future<bool> checkLoginStatus() async {
    return false;
  }

  Future<void> logout() async {
    userId = "";
    userName = "";
    userEmail = "";
    userMobile = "";
    isLoginSuccess.value = false;
    clearData();
  }

  void clearData() {
    emailController.clear();
    passwordController.clear();
    passwordVisible.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
