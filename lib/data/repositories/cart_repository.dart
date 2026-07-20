import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

abstract class CartRepository {
  Future<ApiResult<Map<String, dynamic>>> getCart();
  Future<ApiResult<Map<String, dynamic>>> removeCartItem(String cartItemId);
  Future<ApiResult<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
  });
  Future<ApiResult<Map<String, dynamic>>> applyCoupon({
    required String couponCode,
    required double amount,
  });
}

class ApiCartRepository implements CartRepository {
  ApiCartRepository({UrbanRootsApi? api}) : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  @override
  Future<ApiResult<Map<String, dynamic>>> getCart() => _api.cart.getCart();

  @override
  Future<ApiResult<Map<String, dynamic>>> removeCartItem(String cartItemId) =>
      _api.cart.removeCartItem(cartItemId: cartItemId);

  @override
  Future<ApiResult<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) =>
      _api.cart.updateCartItem(cartItemId: cartItemId, quantity: quantity);

  @override
  Future<ApiResult<Map<String, dynamic>>> applyCoupon({
    required String couponCode,
    required double amount,
  }) =>
      _api.coupons.apply(couponCode: couponCode, amount: amount);
}
