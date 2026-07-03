import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorOrdersController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final orders = <VendorOrderItem>[].obs;
  final selectedTab = 0.obs;

  static const tabs = [
    'All',
    'Pending',
    'Accepted',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  String? get _statusFilter {
    switch (selectedTab.value) {
      case 1:
        return 'pending';
      case 2:
        return 'accepted';
      case 3:
        return 'shipped';
      case 4:
        return 'delivered';
      case 5:
        return 'cancelled';
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

  Future<void> changeTab(int index) async {
    selectedTab.value = index;
    await loadOrders();
  }

  Future<void> acceptOrder(String orderId) async {
    final result = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'accept',
    );
    if (result.error != null) {
      Get.snackbar('Error', result.error!);
      return;
    }
    _applyLocalStatus(orderId, result.newStatus ?? 'Accepted');
    Get.snackbar('Success', 'Order accepted');
    if (selectedTab.value == 1) {
      orders.removeWhere((o) => o.orderId == orderId);
    }
  }

  Future<void> shipOrder(String orderId) async {
    final result = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'ship',
    );
    if (result.error != null) {
      Get.snackbar('Error', result.error!);
      return;
    }
    _applyLocalStatus(orderId, result.newStatus ?? 'Shipped');
    Get.snackbar('Success', 'Order marked as shipped');
    if (selectedTab.value == 2) {
      orders.removeWhere((o) => o.orderId == orderId);
    } else if (selectedTab.value != 3) {
      await changeTab(3);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final result = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'cancel',
    );
    if (result.error != null) {
      Get.snackbar('Error', result.error!);
      return;
    }
    _applyLocalStatus(orderId, result.newStatus ?? 'Cancelled');
    Get.snackbar('Success', 'Order cancelled');
    if (selectedTab.value != 0) {
      orders.removeWhere((o) => o.orderId == orderId);
    }
  }

  void _applyLocalStatus(String orderId, String status) {
    final i = orders.indexWhere((o) => o.orderId == orderId);
    if (i < 0) return;
    final o = orders[i];
    orders[i] = VendorOrderItem(
      orderId: o.orderId,
      customerName: o.customerName,
      amount: o.amount,
      status: status,
    );
  }
}
