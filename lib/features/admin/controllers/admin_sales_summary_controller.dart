import 'package:get/get.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';
import 'package:urban_roots/features/admin/services/admin_api_service.dart';

class AdminSalesSummaryController extends GetxController {
  final AdminApiService _api = AdminApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final summary = <VendorSalesSummaryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Top 5 vendors by products sold — used for the bar chart.
  List<VendorSalesSummaryItem> get topFive {
    final sorted = [...summary]
      ..sort((a, b) => b.productsSoldValue.compareTo(a.productsSoldValue));
    return sorted.take(5).toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.vendorSalesSummary();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    summary.assignAll(result.summary);
  }
}
