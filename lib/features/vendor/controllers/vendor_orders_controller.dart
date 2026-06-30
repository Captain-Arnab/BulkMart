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
    // Backend honours the ?status= filter, so request only the selected tab's
    // orders ("All" passes no param). We still keep a client-side filter in
    // [visibleOrders] as a safety net for any unexpected extra rows.
    final result = await _api.listOrders(status: _statusFilter);
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    orders.assignAll(result.orders);
  }

  /// Orders for the active tab. The backend does not always honour the
  /// `status` query param, so filter client-side as a safety net to keep each
  /// tab accurate.
  List<VendorOrderItem> get visibleOrders {
    final filter = _statusFilter;
    if (filter == null) return orders;
    return orders.where((o) => _matchesStatus(o, filter)).toList();
  }

  bool _matchesStatus(VendorOrderItem order, String filter) {
    final s = order.status.trim().toLowerCase();
    switch (filter) {
      case 'pending':
        return s.contains('pending') || s.contains('placed') || s.isEmpty;
      case 'accepted':
        return s.contains('accept') ||
            s.contains('confirm') ||
            s.contains('process') ||
            s.contains('ship') ||
            s.contains('deliver') ||
            s.contains('complete');
      case 'rejected':
        return s.contains('reject') || s.contains('cancel') || s.contains('declin');
      default:
        return true;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // Re-fetch with the new ?status= filter and show a loading indicator.
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
