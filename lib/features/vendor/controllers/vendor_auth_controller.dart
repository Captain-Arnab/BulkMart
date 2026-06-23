import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';

class VendorAuthController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<bool> sendOtp(String email) async {
    isLoading.value = true;
    errorMessage.value = '';
    final error = await _api.sendRegistrationOtp(email.trim());
    isLoading.value = false;
    if (error != null) {
      errorMessage.value = error;
      return false;
    }
    return true;
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final error = await _api.verifyRegistrationOtp(
      email: email.trim(),
      otp: otp.trim(),
    );
    isLoading.value = false;
    if (error != null) {
      errorMessage.value = error;
      return false;
    }
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final error = await _api.login(email: email.trim(), password: password);
    isLoading.value = false;
    if (error != null) {
      errorMessage.value = error;
      return false;
    }
    return true;
  }
}
