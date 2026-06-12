import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class CartApiService {
  CartApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> addToCart({
    required String productId,
    required int quantity,
    String? deliveryType,
    String? deliveryDate,
    String? weeklyDays,
    String? subscriptionStartDate,
  }) =>
      _client.post(
        APIClass.cartAdd,
        body: {
          'product_id': productId,
          'quantity': quantity,
          if (deliveryType != null) 'delivery_type': deliveryType,
          if (deliveryDate != null) 'delivery_date': deliveryDate,
          if (weeklyDays != null) 'weekly_days': weeklyDays,
          if (subscriptionStartDate != null)
            'subscription_start_date': subscriptionStartDate,
        },
        extraHeaders: cartPlatformHeader,
      );

  Future<ApiResult<Map<String, dynamic>>> getCart() => _client.get(
        APIClass.cartGet,
        extraHeaders: cartPlatformHeader,
      );

  Future<ApiResult<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) =>
      _client.post(
        APIClass.cartUpdate,
        body: {'cart_item_id': cartItemId, 'quantity': quantity},
        extraHeaders: cartPlatformHeader,
      );

  Future<ApiResult<Map<String, dynamic>>> removeCartItem({
    required String cartItemId,
  }) =>
      _client.post(
        APIClass.cartRemove,
        body: {'cart_item_id': cartItemId},
        extraHeaders: cartPlatformHeader,
      );

  /// Unauthenticated — guard in UI layer.
  Future<ApiResult<Map<String, dynamic>>> clearCart({
    required String userId,
  }) =>
      _client.get(
        APIClass.cartClear,
        token: TokenMode.none,
        queryParameters: {'user_id': userId},
        extraHeaders: cartPlatformHeader,
      );

  Future<ApiResult<Map<String, dynamic>>> checkout({
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
    required String paymentMethod,
    required double amount,
  }) =>
      _client.post(
        APIClass.cartCheckout,
        body: {
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
          'payment_method': paymentMethod,
          'amount': amount,
        },
        extraHeaders: cartPlatformHeader,
      );
}
