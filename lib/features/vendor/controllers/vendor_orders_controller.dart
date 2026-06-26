import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorOrdersController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final orders = <VendorOrderItem>[].obs;
  final selectedTab = 0.obs;

  static const tabs = ['All', 'Pending', 'Accepted', 'Rejected'];

  String? get _statusFilter {
    switch (selectedTab.value) {
      case 1:
        return 'pending';
      case 2:
        return 'accepted';
      case 3:
        return 'rejected';
      default:
        return null;
    }
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.listOrders(status: _statusFilter);
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    orders.assignAll(result.orders);
  }

  void changeTab(int index) {
    selectedTab.value = index;
    loadOrders();
  }

  Future<void> acceptOrder(String orderId) async {
    final error = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'accept',
    );
    if (error != null) {
      Get.snackbar('Error', error);
      return;
    }
    Get.snackbar('Success', 'Order accepted');
    await loadOrders();
  }

  Future<void> rejectOrder(String orderId) async {
    final error = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'reject',
    );
    if (error != null) {
      Get.snackbar('Error', error);
      return;
    }
    Get.snackbar('Success', 'Order rejected');
    await loadOrders();
  }
}
