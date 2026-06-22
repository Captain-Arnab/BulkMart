import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';

class OrdersApiService {
  OrdersApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Map<String, dynamic> _orderBody({
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
    required List<Map<String, dynamic>> products,
    String? orderId,
    String? paymentMethod,
  }) {
    final body = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'state': state,
      'city': city,
      'address': address,
      'pincode': pincode.toString(),
      'landmark': landmark.isNotEmpty ? landmark : '-',
      'address_type': addressType,
      'products': products,
    };

    if (orderId != null && orderId.isNotEmpty) {
      body['order_id'] = orderId;
    }
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      body['payment_method'] = paymentMethod;
    }

    return body;
  }

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
    required List<Map<String, dynamic>> products,
    String? orderId,
    String paymentMethod = 'cod',
  }) =>
      _client.post(
        APIClass.codOrder,
        body: _orderBody(
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
          products: products,
          orderId: orderId,
          paymentMethod: paymentMethod,
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> placeWalletOrder({
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
    required List<Map<String, dynamic>> products,
    String? orderId,
  }) =>
      _client.post(
        APIClass.walletOrder,
        body: _orderBody(
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
          products: products,
          orderId: orderId,
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
    required List<Map<String, dynamic>> products,
    String? orderId,
  }) =>
      _client.post(
        APIClass.onlineOrder,
        body: _orderBody(
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
          products: products,
          orderId: orderId,
          paymentMethod: 'online',
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> retryOnlinePayment({
    required OrderPaymentFields fields,
  }) =>
      _client.post(
        APIClass.onlineOrder,
        body: _orderBody(
          firstName: fields.firstName,
          lastName: fields.lastName,
          email: fields.email,
          phone: fields.phone,
          state: fields.state,
          city: fields.city,
          address: fields.address,
          pincode: fields.pincode,
          landmark: fields.landmark,
          addressType: fields.addressType,
          products: fields.products,
          orderId: fields.orderId,
          paymentMethod: 'online',
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> switchOrderToCod({
    required OrderPaymentFields fields,
  }) =>
      _client.post(
        APIClass.codOrder,
        body: _orderBody(
          firstName: fields.firstName,
          lastName: fields.lastName,
          email: fields.email,
          phone: fields.phone,
          state: fields.state,
          city: fields.city,
          address: fields.address,
          pincode: fields.pincode,
          landmark: fields.landmark,
          addressType: fields.addressType,
          products: fields.products,
          orderId: fields.orderId,
          paymentMethod: 'cod',
        ),
      );

  Future<ApiResult<Map<String, dynamic>>> listOrders() =>
      _client.get(APIClass.ordersList);

  Future<ApiResult<Map<String, dynamic>>> orderDetail({
    String? orderId,
    String? txnId,
  }) {
    final params = <String, dynamic>{};
    if (txnId != null && txnId.isNotEmpty) {
      params['txn_id'] = txnId;
    } else if (orderId != null && orderId.isNotEmpty) {
      params['order_id'] = orderId;
    }
    return _client.get(
      APIClass.orderDetail,
      queryParameters: params,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> trackOrder({
    String? txnId,
    String? orderId,
  }) {
    final body = <String, dynamic>{};
    if (txnId != null && txnId.trim().isNotEmpty) {
      body['txn_id'] = txnId.trim();
    } else if (orderId != null && orderId.trim().isNotEmpty) {
      body['order_id'] = orderId.trim();
    }
    return _client.post(
      APIClass.orderTracking,
      body: body,
    );
  }

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
