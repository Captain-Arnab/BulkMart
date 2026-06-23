import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/navigation/vendor_navigation.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorProfileController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final profile = Rxn<VendorProfileData>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.profile();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    profile.value = result.data;
  }

  Future<void> logout() async {
    await AuthSession.instance.clearVendorSession();
    navigateToVendorLogin();
  }
}
