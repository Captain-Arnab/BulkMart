import 'package:dio/dio.dart';
import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class VendorAuthApiService {
  VendorAuthApiService({
    ApiClient? userClient,
    ApiClient? vendorClient,
  })  : _user = userClient ?? ApiClient.user,
        _vendor = vendorClient ?? ApiClient.vendor;

  final ApiClient _user;
  final ApiClient _vendor;

  Future<ApiResult<Map<String, dynamic>>> sendRegistrationOtp({
    required String email,
  }) =>
      _user.post(
        APIClass.vendorSendOtp,
        token: TokenMode.none,
        body: {'email': email},
      );

  Future<ApiResult<Map<String, dynamic>>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) =>
      _user.post(
        APIClass.vendorVerifyOtp,
        token: TokenMode.none,
        body: {'email': email, 'otp': otp},
      );

  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final result = await _vendor.post(
      APIClass.vendorLogin,
      token: TokenMode.none,
      body: {'email': email, 'password': password},
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final data = result.data['data'];
      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        final vendorId = data['vendor_id']?.toString();
        if (token != null && token.isNotEmpty && vendorId != null) {
          await AuthSession.instance.saveVendorSession(
            token: token,
            vendorId: vendorId,
          );
        }
      }
    }
    return result;
  }
}

class VendorPanelApiService {
  VendorPanelApiService({ApiClient? client})
      : _client = client ?? ApiClient.vendor;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> dashboard() => _client.get(
        APIClass.vendorDashboard,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> addCategory({
    required String name,
    required String iconName,
    required String categoryIcon,
  }) =>
      _client.post(
        APIClass.vendorAddCategory,
        token: TokenMode.vendor,
        body: {
          'name': name,
          'icon_name': iconName,
          'category_icon': categoryIcon,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> listProducts() => _client.get(
        APIClass.vendorProductsList,
        token: TokenMode.vendor,
      );

  /// POST /api/vendor/add_vendor_product.php — multipart/form-data.
  /// Text fields are sent as form fields and the picked image is sent as the
  /// `images` file part. [images] is an optional URL/path fallback used only
  /// when no file was picked.
  Future<ApiResult<Map<String, dynamic>>> addProduct({
    required String name,
    required String price,
    required String category,
    required String stock,
    required String gst,
    required String descriptions,
    required String vendorId,
    String images = '',
    String? imagePath,
  }) async {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'gst': gst,
      'descriptions': descriptions,
      'vendor_id': vendorId,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      final fileName = imagePath.split(RegExp(r'[\\/]+')).last;
      map['images'] = await MultipartFile.fromFile(imagePath, filename: fileName);
    } else if (images.isNotEmpty) {
      // Fallback: send the URL/path as a plain field when no file was picked.
      map['images'] = images;
    }

    return _client.post(
      APIClass.vendorAddProduct,
      token: TokenMode.vendor,
      body: FormData.fromMap(map),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateProduct(
    Map<String, dynamic> fields,
  ) =>
      _client.put(
        APIClass.vendorUpdateProduct,
        token: TokenMode.vendor,
        body: fields,
      );

  Future<ApiResult<Map<String, dynamic>>> deleteProduct({
    required String productId,
  }) =>
      _client.delete(
        APIClass.vendorDeleteProduct,
        token: TokenMode.vendor,
        body: {'product_id': productId},
      );

  Future<ApiResult<Map<String, dynamic>>> listOrders({String? status}) =>
      _client.get(
        APIClass.vendorOrdersList,
        token: TokenMode.vendor,
        queryParameters: status != null ? {'status': status} : null,
      );

  /// status.php — the backend's exact field name is unconfirmed, so we send
  /// every plausible shape at once: `action` (accept/ship/cancel), plus the
  /// target `status`/`order_status` string. The backend uses whichever field
  /// it reads and ignores the rest.
  Future<ApiResult<Map<String, dynamic>>> updateOrderStatus({
    required String orderId,
    required String action,
    required String targetStatus,
  }) =>
      _client.post(
        APIClass.vendorOrderStatus,
        token: TokenMode.vendor,
        body: {
          'order_id': orderId,
          'action': action,
          'status': targetStatus,
          'order_status': targetStatus,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> setAvailability({
    required int isOpen,
  }) =>
      _client.post(
        APIClass.vendorAvailability,
        token: TokenMode.vendor,
        body: {'is_open': isOpen.toString()},
      );

  Future<ApiResult<Map<String, dynamic>>> earnings() => _client.get(
        APIClass.vendorEarnings,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> profile() => _client.get(
        APIClass.vendorProfile,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> analytics() => _client.get(
        APIClass.vendorAnalytics,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> payoutHistory() => _client.get(
        APIClass.vendorPayoutHistory,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> supportTickets() => _client.get(
        APIClass.vendorSupportTickets,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> raiseTicket({
    required String subject,
    required String message,
    String? payoutId,
  }) =>
      _client.post(
        APIClass.vendorRaiseTicket,
        token: TokenMode.vendor,
        body: {
          'subject': subject,
          'message': message,
          if (payoutId != null && payoutId.isNotEmpty) 'payout_id': payoutId,
        },
      );
}
