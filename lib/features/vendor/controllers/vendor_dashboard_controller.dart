import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorDashboardController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final dashboard = Rxn<VendorDashboardData>();
  final isOpen = true.obs;
  final isTogglingAvailability = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.dashboard();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    dashboard.value = result.data;
    isOpen.value = result.data?.isOpen ?? true;
  }

  Future<void> toggleAvailability(bool value) async {
    final previous = isOpen.value;
    isOpen.value = value;
    isTogglingAvailability.value = true;
    final error = await _api.setAvailability(isOpen: value);
    isTogglingAvailability.value = false;
    if (error != null) {
      isOpen.value = previous;
      Get.snackbar('Error', error);
    }
  }
}
