import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class OrdersApiService {
  OrdersApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Map<String, dynamic> _orderAddressBody({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String state,
    required String city,
    required String address,
    required String pincode,
    required String landmark,
    required String addressType,
    required String productId,
    required int quantity,
    required double amount,
  }) =>
      {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'state': state,
        'city': city,
        'address': address,
        'pincode': pincode,
        'landmark': landmark,
        'address_type': addressType,
        'product_id': productId,
        'quantity': quantity,
        'amount': amount,
      };

  Future<ApiResult<Map<String, dynamic>>> placeCodOrder({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String state,
    required String city,
    required String address,
    required String pincode,
    required String landmark,
    required String addressType,
    required String productId,
    required int quantity,
    required double amount,
  }) =>
      _client.post(
        APIClass.codOrder,
        body: _orderAddressBody(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          state: state,
          city: city,
          address: address,
          pincode: pincode,
          landmark: landmark,
          addressType: addressType,
          productId: productId,
          quantity: quantity,
          amount: amount,
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> placeOnlineOrder({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String state,
    required String city,
    required String address,
    required String pincode,
    required String landmark,
    required String addressType,
    required String productId,
    required int quantity,
    required double amount,
  }) =>
      _client.post(
        APIClass.onlineOrder,
        body: _orderAddressBody(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          state: state,
          city: city,
          address: address,
          pincode: pincode,
          landmark: landmark,
          addressType: addressType,
          productId: productId,
          quantity: quantity,
          amount: amount,
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> listOrders() =>
      _client.get(APIClass.ordersList);

  Future<ApiResult<Map<String, dynamic>>> orderDetail({
    required String orderId,
  }) =>
      _client.get(
        APIClass.orderDetail,
        queryParameters: {'order_id': orderId},
      );

  Future<ApiResult<Map<String, dynamic>>> trackOrder({
    required String txnId,
  }) =>
      _client.post(
        APIClass.orderTracking,
        body: {'txn_id': txnId},
      );

  Future<ApiResult<Map<String, dynamic>>> cancelOrder({
    required String orderId,
    required String reason,
  }) =>
      _client.post(
        APIClass.cancelOrder,
        body: {'order_id': orderId, 'reason': reason},
      );

  Future<ApiResult<Map<String, dynamic>>> liveTracking({
    required String orderId,
  }) =>
      _client.get(
        APIClass.liveTracking,
        queryParameters: {'order_id': orderId},
      );
}
