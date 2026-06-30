import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/services/vendor_panel_api_service.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

/// Unified vendor API facade — separate from user API services.
class VendorApiService {
  VendorApiService({
    VendorAuthApiService? auth,
    VendorPanelApiService? panel,
  })  : _auth = auth ?? VendorAuthApiService(),
        _panel = panel ?? VendorPanelApiService();

  static final VendorApiService instance = VendorApiService();

  final VendorAuthApiService _auth;
  final VendorPanelApiService _panel;

  Future<String?> sendRegistrationOtp(String email) async {
    final result = await _auth.sendRegistrationOtp(email: email);
    return _errorOrNull(result);
  }

  Future<String?> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    final result = await _auth.verifyRegistrationOtp(email: email, otp: otp);
    return _errorOrNull(result);
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.login(email: email, password: password);
    return _errorOrNull(result);
  }

  Future<({VendorDashboardData? data, String? error})> dashboard() async {
    final result = await _panel.dashboard();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: VendorDashboardData.fromJson((result as ApiSuccess).data),
      error: null
    );
  }

  Future<String?> setAvailability({required bool isOpen}) async {
    final result = await _panel.setAvailability(isOpen: isOpen ? 1 : 0);
    return _errorOrNull(result);
  }

  Future<({List<VendorProductItem> products, String? error})>
      listProducts() async {
    final result = await _panel.listProducts();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (products: <VendorProductItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      products: parseList(data, 'products', VendorProductItem.fromJson),
      error: null,
    );
  }

  Future<String?> addProduct({
    required String name,
    required String price,
    required String category,
    required String stock,
    required String gst,
    required String descriptions,
    String images = '',
    String? imagePath,
  }) async {
    final vendorId = await AuthSession.instance.getVendorId();
    final result = await _panel.addProduct(
      name: name,
      price: price,
      category: category,
      stock: stock,
      gst: gst,
      descriptions: descriptions,
      images: images,
      vendorId: vendorId ?? '',
      imagePath: imagePath,
    );
    return _errorOrNull(result);
  }

  Future<String?> updateProduct(Map<String, dynamic> fields) async {
    final result = await _panel.updateProduct(fields);
    return _errorOrNull(result);
  }

  Future<String?> deleteProduct(String productId) async {
    final result = await _panel.deleteProduct(productId: productId);
    return _errorOrNull(result);
  }

  Future<String?> addCategory({
    required String name,
    required String iconName,
    required String categoryIcon,
  }) async {
    final result = await _panel.addCategory(
      name: name,
      iconName: iconName,
      categoryIcon: categoryIcon,
    );
    return _errorOrNull(result);
  }

  Future<({List<VendorOrderItem> orders, String? error})> listOrders({
    String? status,
  }) async {
    final result = await _panel.listOrders(status: status);
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (orders: <VendorOrderItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      orders: parseList(data, 'orders', VendorOrderItem.fromJson),
      error: null,
    );
  }

  Future<({String? error, String? newStatus})> updateOrderStatus({
    required String orderId,
    required String action,
    required String targetStatus,
  }) async {
    final result = await _panel.updateOrderStatus(
      orderId: orderId,
      action: action,
      targetStatus: targetStatus,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      if (kDebugMode) {
        debugPrint('[VENDOR_ORDER_STATUS] FAIL action=$action '
            'order=$orderId → ${result.message}');
      }
      // The backend's status.php and list.php can disagree: list.php may still
      // report an order as "Pending" while status.php already has it as
      // "Shipped"/"Cancelled". In that case status.php fails with a message
      // like: Order #109 is already marked as 'Shipped'. We treat that as a
      // success and reconcile the UI to the status the backend reports.
      final alreadyStatus = _statusFromAlreadyMarked(result.message);
      if (alreadyStatus != null) {
        return (error: null, newStatus: alreadyStatus);
      }
      return (error: result.message, newStatus: null);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    if (kDebugMode) {
      debugPrint('[VENDOR_ORDER_STATUS] OK action=$action order=$orderId '
          'target=$targetStatus → $data');
    }
    return (error: null, newStatus: _extractOrderStatusFromResponse(data));
  }

  /// Detect a backend "already marked as 'X'" message and return X, so the UI
  /// can self-heal when list.php lags behind status.php.
  String? _statusFromAlreadyMarked(String? message) {
    if (message == null) return null;
    final lower = message.toLowerCase();
    if (!lower.contains('already')) return null;
    for (final s in const ['Shipped', 'Cancelled', 'Completed', 'Pending']) {
      if (lower.contains(s.toLowerCase())) return s;
    }
    return null;
  }

  /// Pull the updated order status from a status.php success envelope.
  String? _extractOrderStatusFromResponse(Map<String, dynamic> data) {
    for (final key in ['new_status', 'order_status', 'status']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty && v.trim().toLowerCase() != 'true') {
        return v.trim();
      }
    }
    final nested = data['data'];
    if (nested is Map) {
      final map = Map<String, dynamic>.from(nested);
      for (final key in ['new_status', 'order_status', 'status']) {
        final v = map[key];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString().trim();
        }
      }
    }
    return null;
  }

  Future<({VendorEarningsData? data, String? error})> earnings() async {
    final result = await _panel.earnings();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: VendorEarningsData.fromJson((result as ApiSuccess).data),
      error: null,
    );
  }

  Future<({VendorProfileData? data, String? error})> profile() async {
    final result = await _panel.profile();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: VendorProfileData.fromJson((result as ApiSuccess).data),
      error: null,
    );
  }

  Future<({VendorAnalyticsData? data, String? error})> analytics() async {
    final result = await _panel.analytics();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (data: null, error: result.message);
    }
    return (
      data: VendorAnalyticsData.fromJson((result as ApiSuccess).data),
      error: null,
    );
  }

  Future<({List<PayoutHistoryItem> payouts, String? error})>
      payoutHistory() async {
    final result = await _panel.payoutHistory();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (payouts: <PayoutHistoryItem>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      payouts: parseList(data, 'payouts', PayoutHistoryItem.fromJson),
      error: null,
    );
  }

  Future<({List<SupportTicket> tickets, String? error})>
      supportTickets() async {
    final result = await _panel.supportTickets();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (tickets: <SupportTicket>[], error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    return (
      tickets: parseList(data, 'tickets', SupportTicket.fromJson),
      error: null,
    );
  }

  /// Returns the new ticket id on success, or an error message on failure.
  Future<({String? ticketId, String? error})> raiseTicket({
    required String subject,
    required String message,
    String? payoutId,
  }) async {
    final result = await _panel.raiseTicket(
      subject: subject,
      message: message,
      payoutId: payoutId,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (ticketId: null, error: result.message);
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final ticketId = data['ticket_id']?.toString() ??
        (data['data'] is Map
            ? (data['data'] as Map)['ticket_id']?.toString()
            : null);
    return (ticketId: ticketId, error: null);
  }

  String? _errorOrNull(ApiResult<Map<String, dynamic>> result) {
    if (result is ApiFailure<Map<String, dynamic>>) return result.message;
    return null;
  }
}
