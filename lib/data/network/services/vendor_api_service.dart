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

  Future<String?> updateOrderStatus({
    required String orderId,
    required String action,
  }) async {
    final result = await _panel.updateOrderStatus(
      orderId: orderId,
      action: action,
    );
    return _errorOrNull(result);
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

  Future<({List<VendorDirectoryItem> vendors, String? error})>
      vendorList() async {
    final result = await _panel.vendorList();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return (vendors: <VendorDirectoryItem>[], error: result.message);
    }
    final envelope = (result as ApiSuccess<Map<String, dynamic>>).data;
    final data = envelope['data'];
    final vendors = data is Map
        ? parseList(
            Map<String, dynamic>.from(data),
            'vendors',
            VendorDirectoryItem.fromJson,
          )
        : parseList(envelope, 'vendors', VendorDirectoryItem.fromJson);
    return (vendors: vendors, error: null);
  }

  String? _errorOrNull(ApiResult<Map<String, dynamic>> result) {
    if (result is ApiFailure<Map<String, dynamic>>) return result.message;
    return null;
  }
}
