import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorEarningsController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final earnings = Rxn<VendorEarningsData>();

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.earnings();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    earnings.value = result.data;
  }
}
