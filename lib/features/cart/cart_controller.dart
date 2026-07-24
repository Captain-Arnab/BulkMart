import 'package:get/get.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/cart/models/available_coupon.dart';
import 'package:urban_roots/features/offers/models/offer_model.dart';

class CartController extends GetxController {
  CartController({UrbanRootsApi? api}) : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> summary = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString updatingItemId = ''.obs;

  final RxString appliedCoupon = ''.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble finalAmount = 0.0.obs;

  /// Caches catalog product detail by product id for the session so repeated
  /// cart loads (quantity change, remove, re-open) don't re-fetch heavy
  /// product-view payloads for items already seen.
  final Map<String, Map<String, dynamic>> _productDetailCache = {};

  static CartController findOrPut() {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  Map<String, dynamic>? findItemByProductId(String productId) {
    final id = productId.trim();
    if (id.isEmpty) return null;
    for (final item in items) {
      final pid = item['product_id']?.toString() ??
          item['pd_id']?.toString() ??
          '';
      if (pid == id) return item;
    }
    return null;
  }

  int quantityForProduct(String productId) {
    final item = findItemByProductId(productId);
    if (item == null) return 0;
    return int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
  }

  String? cartItemIdForProduct(String productId) {
    return findItemByProductId(productId)?['cart_item_id']?.toString();
  }

  double get totalValue {
    final summaryTotal = summary['total'] ??
        summary['grand_total'] ??
        summary['subtotal'] ??
        summary['amount'];
    if (summaryTotal != null) {
      return double.tryParse(summaryTotal.toString()) ?? 0;
    }
    var total = 0.0;
    for (final item in items) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      total += price * qty;
    }
    return total;
  }

  Future<bool> addProduct(
    String productId, {
    int quantity = 1,
    String? deliveryType,
    String? deliveryDate,
    String? weeklyDays,
    String? subscriptionStartDate,
  }) async {
    final id = productId.trim();
    if (id.isEmpty) {
      errorMessage.value = 'Invalid product';
      return false;
    }

    errorMessage.value = '';
    final result = await _api.cart.addToCart(
      productId: id,
      quantity: quantity,
      deliveryType: deliveryType,
      deliveryDate: deliveryDate,
      weeklyDays: weeklyDays,
      subscriptionStartDate: subscriptionStartDate,
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
      summary.clear();
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final parsed = _parseCartItems(data);
    await _enrichFromCatalog(parsed);
    items.assignAll(parsed);
    _applySummary(data);
    await reapplyCouponIfNeeded();
  }

  void _applySummary(Map<String, dynamic> envelope) {
    Map<String, dynamic>? summarySource;
    if (envelope['summary'] is Map) {
      summarySource = Map<String, dynamic>.from(envelope['summary'] as Map);
    } else if (envelope['data'] is Map) {
      final inner = Map<String, dynamic>.from(envelope['data'] as Map);
      if (inner['summary'] is Map) {
        summarySource = Map<String, dynamic>.from(inner['summary'] as Map);
      }
    }

    if (summarySource != null) {
      summary.assignAll(summarySource);
    } else {
      summary.clear();
    }
  }

  List<Map<String, dynamic>> _parseCartItems(Map<String, dynamic> envelope) {
    final rawItems = _extractCartItemList(envelope);
    return rawItems.map(_normalizeCartItem).toList();
  }

  List<Map<String, dynamic>> _extractCartItemList(Map<String, dynamic> envelope) {
    for (final key in ['cart_items', 'items', 'cart', 'products']) {
      final value = envelope[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    final inner = envelope['data'];
    if (inner is List) {
      return inner
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (inner is Map) {
      final map = Map<String, dynamic>.from(inner);
      for (final key in ['cart_items', 'items', 'cart', 'products']) {
        final value = map[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    return extractList(envelope)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _normalizeCartItem(Map<String, dynamic> item) {
    final normalized = Map<String, dynamic>.from(item);

    normalized['cart_item_id'] ??= normalized['cart_id'] ?? normalized['id'];
    normalized['product_id'] ??= normalized['pd_id'] ?? normalized['productId'];
    normalized['name'] ??= normalized['product_name'] ?? normalized['item_name'];
    normalized['quantity'] ??= normalized['qty'] ?? 1;
    normalized['price'] ??= normalized['product_price'] ??
        normalized['unit_price'] ??
        normalized['item_price'] ??
        normalized['rate'] ??
        '0';

    final imageUrl = pickImageUrl(normalized);
    if (imageUrl.isNotEmpty) {
      normalized['imageUrl'] = imageUrl;
    }
    return normalized;
  }

  Future<void> _enrichFromCatalog(List<Map<String, dynamic>> cartItems) async {
    final futures = <Future<void>>[];
    for (final item in cartItems) {
      final productId = item['product_id']?.toString() ??
          item['pd_id']?.toString() ??
          '';
      if (productId.isEmpty) continue;

      // Use the cached detail when available — avoids re-fetching the heavy
      // product-view payload on every cart reload.
      final cached = _productDetailCache[productId];
      if (cached != null) {
        _applyProductDetail(item, cached);
        continue;
      }

      futures.add(() async {
        final result = await _api.catalog.productDetail(productId: productId);
        if (result is! ApiSuccess<Map<String, dynamic>>) return;
        final data =
            result.data['data'] ?? result.data['product'] ?? result.data;
        if (data is! Map) return;

        final product = Map<String, dynamic>.from(data);
        _productDetailCache[productId] = product;
        _applyProductDetail(item, product);
      }());
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  void _applyProductDetail(
    Map<String, dynamic> item,
    Map<String, dynamic> product,
  ) {
    final imageUrl = pickImageUrl(product);
    if (imageUrl.isNotEmpty) {
      item['imageUrl'] = imageUrl;
    }

    final productName = product['name']?.toString() ??
        product['product_name']?.toString() ??
        product['pd_name']?.toString();
    if (productName != null && productName.trim().isNotEmpty) {
      item['name'] = productName.trim();
    }

    final grams = product['grams']?.toString() ??
        product['product_grams']?.toString() ??
        product['weight']?.toString();
    if (grams != null && grams.trim().isNotEmpty) {
      item['product_grams'] = grams.trim();
    }
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (cartItemId.isEmpty) {
      errorMessage.value = 'Invalid cart item';
      return false;
    }
    if (quantity < 1) {
      return removeItem(cartItemId);
    }

    updatingItemId.value = cartItemId;
    final result = await _api.cart.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );
    updatingItemId.value = '';
    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      return false;
    }
    await loadCart();
    return true;
  }

  Future<bool> removeItem(String cartItemId) async {
    if (cartItemId.isEmpty) {
      errorMessage.value = 'Invalid cart item';
      return false;
    }

    // Remove the item from the list in the same synchronous frame the request
    // starts. Swipe-to-delete (Dismissible) requires the dismissed item to be
    // gone from its data source immediately — otherwise Flutter asserts that a
    // "dismissed Dismissible widget is still part of the tree" and the app
    // crashes on the next delete. We restore the item if the server rejects it.
    final index = items.indexWhere(
      (e) => e['cart_item_id']?.toString() == cartItemId,
    );
    final Map<String, dynamic>? removedItem =
        index != -1 ? items[index] : null;
    if (index != -1) {
      items.removeAt(index);
    }

    updatingItemId.value = cartItemId;
    final result = await _api.cart.removeCartItem(cartItemId: cartItemId);
    updatingItemId.value = '';

    if (result is ApiFailure) {
      errorMessage.value = (result as ApiFailure).message;
      if (removedItem != null) {
        items.insert(index.clamp(0, items.length), removedItem);
      }
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
      final result = await _api.cart.clearCart();
      if (result is ApiFailure<Map<String, dynamic>>) {
        errorMessage.value = result.message;
        await loadCart();
        return false;
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
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return const ApiFailure('Enter a coupon code');
    }

    final result = await _api.coupons.apply(
      couponCode: trimmed,
      amount: totalValue,
    );
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final d = result.data;
      final inner = d['data'] is Map
          ? Map<String, dynamic>.from(d['data'] as Map)
          : d;
      appliedCoupon.value =
          inner['coupon_code']?.toString() ?? d['coupon_code']?.toString() ?? trimmed;
      discount.value = double.tryParse(
            inner['discount']?.toString() ?? d['discount']?.toString() ?? '0',
          ) ??
          0;
      finalAmount.value = double.tryParse(
            inner['final_amount']?.toString() ??
                d['final_amount']?.toString() ??
                '',
          ) ??
          (totalValue - discount.value);
    }
    return result;
  }

  /// Coupons from `/coupons/list.php`, plus active offer promo codes when the
  /// coupons table is empty (common on current backend).
  Future<List<AvailableCoupon>> fetchAvailableCoupons() async {
    final byCode = <String, AvailableCoupon>{};

    final couponsResult = await _api.coupons.list();
    if (couponsResult is ApiSuccess<Map<String, dynamic>>) {
      final raw = couponsResult.data['coupons'] ??
          couponsResult.data['data'] ??
          couponsResult.data['list'];
      if (raw is List) {
        for (final entry in raw.whereType<Map>()) {
          final map = Map<String, dynamic>.from(entry);
          final code = (map['coupon_code'] ??
                  map['code'] ??
                  map['promo_code'] ??
                  map['coupon'])
              ?.toString()
              .trim();
          if (code == null || code.isEmpty) continue;
          final key = code.toUpperCase();
          byCode[key] = AvailableCoupon(
            code: key,
            title: (map['title'] ?? map['name'] ?? map['coupon_title'])
                    ?.toString() ??
                '',
            description:
                (map['description'] ?? map['details'] ?? map['message'])
                        ?.toString() ??
                    '',
            discountPercent: int.tryParse(
                  (map['discount_percent'] ??
                          map['discount'] ??
                          map['percent_off'] ??
                          '0')
                      .toString(),
                ) ??
                0,
          );
        }
      }
    }

    // Offers API exposes live promo codes even when coupons/list is empty.
    final offersResult = await _api.offers.listOffers();
    if (offersResult is ApiSuccess<Map<String, dynamic>>) {
      final raw = offersResult.data['offers'] ?? offersResult.data['data'];
      if (raw is List) {
        for (final entry in raw.whereType<Map>()) {
          final offer =
              OfferModel.fromJson(Map<String, dynamic>.from(entry));
          final code = offer.couponCode.trim();
          if (code.isEmpty) continue;
          final key = code.toUpperCase();
          byCode.putIfAbsent(
            key,
            () => AvailableCoupon(
              code: key,
              title: offer.displayTitle,
              description: offer.displayDescription,
              discountPercent: offer.discountPercent,
            ),
          );
        }
      }
    }

    final list = byCode.values.toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return list;
  }

  /// Clears the applied coupon via coupons/remove.php and uses the
  /// server-returned discount / final_amount.
  Future<void> removeCoupon() async {
    final hadCoupon = appliedCoupon.value.trim().isNotEmpty;
    if (!hadCoupon) {
      discount.value = 0;
      finalAmount.value = totalValue;
      return;
    }

    final result = await _api.coupons.remove();
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final d = result.data;
      final inner = d['data'] is Map
          ? Map<String, dynamic>.from(d['data'] as Map)
          : d;
      appliedCoupon.value = '';
      discount.value = double.tryParse(
            inner['discount']?.toString() ?? d['discount']?.toString() ?? '0',
          ) ??
          0;
      finalAmount.value = double.tryParse(
            inner['final_amount']?.toString() ??
                d['final_amount']?.toString() ??
                '',
          ) ??
          totalValue;
      return;
    }

    // Fall back to local clear if the API call fails so the user isn't stuck.
    appliedCoupon.value = '';
    discount.value = 0;
    finalAmount.value = totalValue;
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
    }
  }

  /// Re-sends the applied coupon against the current cart total.
  Future<void> reapplyCouponIfNeeded() async {
    final code = appliedCoupon.value.trim();
    if (code.isEmpty) {
      finalAmount.value = totalValue;
      return;
    }
    final result = await applyCoupon(code);
    if (result is ApiFailure<Map<String, dynamic>>) {
      // Keep the code visible but fall back to undiscounted total.
      discount.value = 0;
      finalAmount.value = totalValue;
      errorMessage.value = result.message;
    }
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
