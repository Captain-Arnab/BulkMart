import 'package:get/get.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
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

  Future<bool> addProduct(String productId, {int quantity = 1}) async {
    final result = await _api.cart.addToCart(
      productId: productId,
      quantity: quantity,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return false;
    }
    await loadCart();
    return true;
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
    final parsed = _parseCartItems(data);
    await _enrichMissingImages(parsed);
    items.assignAll(parsed);
    final summarySource = data['summary'] is Map
        ? data['summary']
        : (data['data'] is Map ? (data['data'] as Map)['summary'] : null);
    if (summarySource is Map) {
      summary.assignAll(Map<String, dynamic>.from(summarySource));
    }
    finalAmount.value = totalValue - discount.value;
  }

  List<Map<String, dynamic>> _parseCartItems(Map<String, dynamic> envelope) {
    List<Map<String, dynamic>> rawItems;
    final inner = envelope['data'];
    if (inner is List) {
      rawItems = inner
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (inner is Map) {
      rawItems = [];
      for (final key in ['items', 'cart', 'products']) {
        final value = inner[key];
        if (value is List) {
          rawItems = value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          break;
        }
      }
    } else {
      rawItems = extractList(envelope)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return rawItems.map(_normalizeCartItem).toList();
  }

  Map<String, dynamic> _normalizeCartItem(Map<String, dynamic> item) {
    final normalized = Map<String, dynamic>.from(item);
    if (normalized['cart_item_id'] == null && normalized['id'] != null) {
      normalized['cart_item_id'] = normalized['id'];
    }
    final imageUrl = pickImageUrl(normalized);
    if (imageUrl.isNotEmpty) {
      normalized['imageUrl'] = imageUrl;
    }
    return normalized;
  }

  Future<void> _enrichMissingImages(List<Map<String, dynamic>> items) async {
    final futures = <Future<void>>[];
    for (final item in items) {
      if (pickImageUrl(item).isNotEmpty) continue;
      final productId = item['product_id']?.toString() ??
          item['pd_id']?.toString() ??
          '';
      if (productId.isEmpty) continue;
      futures.add(() async {
        final result = await _api.catalog.productDetail(productId: productId);
        if (result is ApiSuccess<Map<String, dynamic>>) {
          final data = result.data['data'];
          if (data is Map) {
            final imageUrl = pickImageUrl(Map<String, dynamic>.from(data));
            if (imageUrl.isNotEmpty) {
              item['imageUrl'] = imageUrl;
            }
          }
        }
      }());
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
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
    if (items.isEmpty) return true;

    isLoading(true);
    errorMessage.value = '';

    try {
      // Backend /cart/clear.php returns success but does not actually empty the cart.
      // Remove each line item via /cart/remove.php instead.
      final ids = items
          .map((item) =>
              item['cart_item_id']?.toString() ?? item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      if (ids.isEmpty) {
        errorMessage.value = 'Could not identify cart items to remove';
        return false;
      }

      for (final cartItemId in ids) {
        final result = await _api.cart.removeCartItem(cartItemId: cartItemId);
        if (result is ApiFailure<Map<String, dynamic>>) {
          errorMessage.value = result.message;
          await loadCart();
          return false;
        }
      }

      appliedCoupon.value = '';
      discount.value = 0;
      finalAmount.value = 0;
      summary.clear();
      await loadCart();
      return items.isEmpty;
    } finally {
      isLoading(false);
    }
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
    return _api.cart.checkout(
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      state: '',
      city: '',
      address: '',
      pincode: '',
      landmark: '',
      addressType: 'home',
      paymentMethod: 'cod',
      amount: totalValue,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> checkoutCart({
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
      _api.cart.checkout(
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
        paymentMethod: paymentMethod,
        amount: amount,
      );
}
