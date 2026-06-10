import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool passwordVisible = false.obs;
  RxBool isLoading = false.obs;
  Rx<AuthRole> selectedRole = AuthRole.user.obs;
  bool isLoginSuccess = false;
  String userId = "USR001";
  String userName = "Arnab Som";
  String userEmail = "arnab@urbanroots.com";
  String userMobile = "+91 97385 50132";

  Future<void> userLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    isLoading(true);

    await Future.delayed(const Duration(milliseconds: 800));

    isLoginSuccess = true;
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
    isLoginSuccess = false;
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
