import 'package:get/get.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';
import 'package:urban_roots/features/admin/services/admin_api_service.dart';

class AdminPayoutReportController extends GetxController {
  final AdminApiService _api = AdminApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final report = <VendorPayoutReportItem>[].obs;
  final selectedVendorId = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Distinct vendors for the filter dropdown (built from the loaded report).
  final allVendors = <VendorPayoutReportItem>[].obs;

  double get totalPayable =>
      report.fold(0.0, (sum, e) => sum + e.payableValue);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result =
        await _api.vendorPayoutReport(vendorId: selectedVendorId.value);
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    report.assignAll(result.report);
    // Keep the master vendor list only when showing "All".
    if (selectedVendorId.value == null) {
      allVendors.assignAll(result.report);
    }
  }

  void filterByVendor(String? vendorId) {
    selectedVendorId.value = vendorId;
    load();
  }
}
