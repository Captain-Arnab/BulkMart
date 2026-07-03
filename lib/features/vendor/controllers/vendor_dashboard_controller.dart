import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorDashboardController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final dashboard = Rxn<VendorDashboardData>();
  final analytics = Rxn<VendorAnalyticsData>();
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
    if (result.error != null) {
      isLoading.value = false;
      errorMessage.value = result.error!;
      return;
    }
    dashboard.value = result.data;
    isOpen.value = result.data?.isOpen ?? true;

    // Analytics for inline charts — failure must not block the dashboard.
    final analyticsResult = await _api.analytics();
    if (analyticsResult.error == null) {
      analytics.value = analyticsResult.data;
    }
    isLoading.value = false;
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
