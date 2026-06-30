import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorOrdersController extends GetxController {
  final VendorApiService _api = VendorApiService.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final orders = <VendorOrderItem>[].obs;
  final selectedTab = 0.obs;

  // Mirrors the backend's actual order statuses (Pending / Shipped /
  // Completed / Cancelled) as shown on the vendor web panel.
  static const tabs = ['All', 'Pending', 'Shipped', 'Completed', 'Cancelled'];

  // Statuses we changed this session. The backend's list.php can lag behind
  // status.php (returning an order as "Pending" after it was already shipped),
  // so we re-apply these known-good statuses after every reload.
  final Map<String, String> _statusOverrides = {};

  String? get _statusFilter {
    switch (selectedTab.value) {
      case 1:
        return 'pending';
      case 2:
        return 'shipped';
      case 3:
        return 'completed';
      case 4:
        return 'cancelled';
      default:
        return null;
    }
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _api.listOrders();
    isLoading.value = false;
    if (result.error != null) {
      errorMessage.value = result.error!;
      return;
    }
    orders.assignAll(result.orders);
    _reapplyOverrides();
    if (kDebugMode) {
      debugPrint('[VENDOR_ORDERS] count=${result.orders.length}');
      for (final o in result.orders) {
        debugPrint('[VENDOR_ORDERS]   #${o.orderId} status="${o.status}"');
      }
    }
  }

  /// Orders for the active tab, filtered client-side from the full list.
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
      case 'shipped':
        return s.contains('ship') ||
            s.contains('accept') ||
            s.contains('process') ||
            s.contains('confirm');
      case 'completed':
        return s.contains('complet') || s.contains('deliver');
      case 'cancelled':
        return s.contains('cancel') ||
            s.contains('reject') ||
            s.contains('declin');
      default:
        return true;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Mark a pending order as shipped (web panel truck action → status Shipped).
  Future<void> shipOrder(String orderId) async {
    final result = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'ship',
      targetStatus: 'Shipped',
    );
    if (result.error != null) {
      Get.snackbar('Error', result.error!);
      return;
    }
    _applyLocalStatus(orderId, result.newStatus ?? 'Shipped');
    Get.snackbar('Success', 'Order marked as shipped');
    selectedTab.value = 2; // Shipped tab
    await loadOrders();
  }

  /// Cancel a pending order (web panel → status Cancelled).
  Future<void> cancelOrder(String orderId) async {
    final result = await _api.updateOrderStatus(
      orderId: orderId,
      action: 'cancel',
      targetStatus: 'Cancelled',
    );
    if (result.error != null) {
      Get.snackbar('Error', result.error!);
      return;
    }
    _applyLocalStatus(orderId, result.newStatus ?? 'Cancelled');
    Get.snackbar('Success', 'Order cancelled');
    selectedTab.value = 4; // Cancelled tab
    await loadOrders();
  }

  void _applyLocalStatus(String orderId, String status) {
    _statusOverrides[orderId] = status;
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

  /// Re-apply this session's known statuses on top of a freshly fetched list,
  /// guarding against a lagging backend that still reports the old status.
  void _reapplyOverrides() {
    if (_statusOverrides.isEmpty) return;
    for (var i = 0; i < orders.length; i++) {
      final o = orders[i];
      final override = _statusOverrides[o.orderId];
      if (override == null || override == o.status) continue;
      orders[i] = VendorOrderItem(
        orderId: o.orderId,
        customerName: o.customerName,
        amount: o.amount,
        status: override,
      );
    }
  }
}
