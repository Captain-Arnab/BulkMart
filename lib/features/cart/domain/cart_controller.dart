import 'package:get/get.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class CartController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> summary = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString appliedCoupon = ''.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble finalAmount = 0.0.obs;

  double get totalValue {
    if (summary['total'] != null) {
      return double.tryParse(summary['total'].toString()) ?? 0;
    }
    var total = 0.0;
    for (final item in items) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      total += price * qty;
    }
    return total;
  }

  Future<void> loadCart() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.cart.getCart();
    isLoading(false);
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      items.clear();
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    items.assignAll(
      extractList(data).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
    );
    if (data['summary'] is Map) {
      summary.assignAll(Map<String, dynamic>.from(data['summary'] as Map));
    }
    finalAmount.value = totalValue - discount.value;
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    final result = await _api.cart.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );
    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      return false;
    }
    await loadCart();
    return true;
  }

  Future<bool> removeItem(String cartItemId) async {
    final result = await _api.cart.removeCartItem(cartItemId: cartItemId);
    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      return false;
    }
    await loadCart();
    return true;
  }

  Future<bool> clearCart() async {
    final userId = await AuthSession.instance.getUserId();
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'User ID not found';
      return false;
    }
    final result = await _api.cart.clearCart(userId: userId);
    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      return false;
    }
    await loadCart();
    return true;
  }

  Future<ApiResult<Map<String, dynamic>>> applyCoupon(String code) async {
    final result = await _api.coupons.apply(
      couponCode: code,
      amount: totalValue,
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final d = result.data;
      appliedCoupon.value = d['coupon_code']?.toString() ?? code;
      discount.value = double.tryParse(d['discount']?.toString() ?? '0') ?? 0;
      finalAmount.value =
          double.tryParse(d['final_amount']?.toString() ?? '') ?? (totalValue - discount.value);
    }
    return result;
  }

  Future<void> removeCoupon() async {
    await _api.coupons.remove();
    appliedCoupon.value = '';
    discount.value = 0;
    finalAmount.value = totalValue;
  }

  Future<ApiResult<Map<String, dynamic>>> checkout() async {
    final userId = await AuthSession.instance.getUserId();
    return _api.cart.checkout(userId: userId ?? '');
  }
}
