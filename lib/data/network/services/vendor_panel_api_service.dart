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
  VendorPanelApiService({ApiClient? client}) : _client = client ?? ApiClient.vendor;
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

  Future<ApiResult<Map<String, dynamic>>> addProduct({
    required String name,
    required double price,
    required String category,
    required int stock,
    required double gst,
    required String descriptions,
    required List<MultipartFile> images,
  }) async {
    final vendorId = await AuthSession.instance.getVendorId();
    final formData = FormData.fromMap({
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'gst': gst,
      'descriptions': descriptions,
      'images': images,
      if (vendorId != null) 'vendor_id': vendorId,
    });
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        APIClass.vendorAddProduct,
        data: formData,
        options: Options(extra: {'tokenMode': TokenMode.vendor}),
      );
      final data = response.data;
      if (data == null) return const ApiFailure('Empty response');
      if (data['status'] != true) {
        return ApiFailure(data['message'] as String? ?? 'Request failed');
      }
      return ApiSuccess(data);
    } on DioException catch (e) {
      return ApiFailure(e.message ?? 'Network error');
    }
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

  Future<ApiResult<Map<String, dynamic>>> updateOrderStatus({
    required String orderId,
    required String action,
  }) =>
      _client.post(
        APIClass.vendorOrderStatus,
        token: TokenMode.vendor,
        body: {'order_id': orderId, 'action': action},
      );

  Future<ApiResult<Map<String, dynamic>>> setAvailability({
    required int isOpen,
  }) =>
      _client.post(
        APIClass.vendorAvailability,
        token: TokenMode.vendor,
        body: {'is_open': isOpen},
      );

  Future<ApiResult<Map<String, dynamic>>> earnings() => _client.get(
        APIClass.vendorEarnings,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> profile() => _client.get(
        APIClass.vendorProfile,
        token: TokenMode.vendor,
      );

  Future<ApiResult<Map<String, dynamic>>> vendorList() => _client.get(
        APIClass.vendorList,
        token: TokenMode.vendor,
      );
}
