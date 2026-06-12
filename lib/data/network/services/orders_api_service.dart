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
    required double amount,
    List<Map<String, dynamic>>? products,
    String? productId,
    int quantity = 1,
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
      'amount': amount,
    };

    final resolvedProductId = productId ??
        (products != null && products.isNotEmpty
            ? products.first['product_id']?.toString()
            : null);
    final resolvedQuantity = productId != null
        ? quantity
        : (products != null && products.isNotEmpty
            ? int.tryParse(products.first['quantity']?.toString() ?? '1') ?? 1
            : quantity);

    if (resolvedProductId != null && resolvedProductId.isNotEmpty) {
      body['product_id'] = resolvedProductId;
      body['quantity'] = resolvedQuantity;
    }

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
    required double amount,
    List<Map<String, dynamic>>? products,
    String? productId,
    int quantity = 1,
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
          amount: amount,
          products: products,
          productId: productId,
          quantity: quantity,
          orderId: orderId,
          paymentMethod: paymentMethod,
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
    required double amount,
    List<Map<String, dynamic>>? products,
    String? productId,
    int quantity = 1,
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
          amount: amount,
          products: products,
          productId: productId,
          quantity: quantity,
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
          amount: fields.amount,
          productId: fields.productId,
          quantity: fields.quantity,
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
          amount: fields.amount,
          productId: fields.productId,
          quantity: fields.quantity,
          orderId: fields.orderId,
          paymentMethod: 'cod',
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
