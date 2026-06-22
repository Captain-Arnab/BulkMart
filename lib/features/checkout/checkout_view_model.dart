import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';
import 'package:urban_roots/features/wallet/wallet_controller.dart';

class CheckoutOrderResult {
  const CheckoutOrderResult({
    required this.orderId,
    this.txnId,
    this.paymentUrl,
    this.walletBalance,
  });

  final String orderId;
  final String? txnId;
  final String? paymentUrl;
  final double? walletBalance;
}

typedef CheckoutAddressFields = Map<String, String>;

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({UrbanRootsApi? api}) : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  UiState<CheckoutOrderResult>? placeOrderState;

  bool get isPlacingOrder => placeOrderState is UiLoading;

  void resetPlaceOrderState() {
    placeOrderState = null;
    notifyListeners();
  }

  Future<CheckoutOrderResult?> placeOrderWithCod({
    required CartController cart,
    required CheckoutAddressFields address,
    required List<Map<String, dynamic>> products,
    required double payable,
  }) =>
      _placeOrder(
        cart: cart,
        address: address,
        products: products,
        paymentMethod: 'cod',
        payable: payable,
        orderApiCall: () => _api.orders.placeCodOrder(
          firstName: address['firstName']!,
          lastName: address['lastName']!,
          email: address['email']!,
          phone: address['phone']!,
          state: address['state']!,
          city: address['city']!,
          address: address['address']!,
          pincode: address['pincode']!,
          landmark: address['landmark']!,
          addressType: address['addressType']!,
          products: products,
          paymentMethod: 'cod',
        ),
      );

  Future<CheckoutOrderResult?> placeOrderWithOnline({
    required CartController cart,
    required CheckoutAddressFields address,
    required List<Map<String, dynamic>> products,
    required double payable,
  }) =>
      _placeOrder(
        cart: cart,
        address: address,
        products: products,
        paymentMethod: 'online',
        payable: payable,
        orderApiCall: () => _api.orders.placeOnlineOrder(
          firstName: address['firstName']!,
          lastName: address['lastName']!,
          email: address['email']!,
          phone: address['phone']!,
          state: address['state']!,
          city: address['city']!,
          address: address['address']!,
          pincode: address['pincode']!,
          landmark: address['landmark']!,
          addressType: address['addressType']!,
          products: products,
        ),
      );

  Future<CheckoutOrderResult?> placeOrderWithWallet({
    required CartController cart,
    required CheckoutAddressFields address,
    required List<Map<String, dynamic>> products,
    required double payable,
  }) async {
    final wallet = WalletController.findOrPut();
    await wallet.loadBalance();
    if (wallet.balance.value < payable) {
      placeOrderState = UiError(
        'Insufficient wallet balance. Available: ₹${wallet.balance.value.toStringAsFixed(0)}',
      );
      notifyListeners();
      return null;
    }

    placeOrderState = const UiLoading();
    notifyListeners();

    await cart.checkoutCart(
      firstName: address['firstName']!,
      lastName: address['lastName']!,
      email: address['email']!,
      phone: address['phone']!,
      state: address['state']!,
      city: address['city']!,
      address: address['address']!,
      pincode: address['pincode']!,
      landmark: address['landmark']!,
      addressType: address['addressType']!,
      paymentMethod: 'wallet',
      amount: payable,
    );

    final result = await _api.orders.placeWalletOrder(
      firstName: address['firstName']!,
      lastName: address['lastName']!,
      email: address['email']!,
      phone: address['phone']!,
      state: address['state']!,
      city: address['city']!,
      address: address['address']!,
      pincode: address['pincode']!,
      landmark: address['landmark']!,
      addressType: address['addressType']!,
      products: products,
    );

    if (result is ApiFailure<Map<String, dynamic>>) {
      placeOrderState = UiError(result.message);
      notifyListeners();
      await wallet.loadBalance();
      return null;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final orderResult = CheckoutOrderResult(
      orderId: extractOrderId(data) ?? '',
      txnId: extractTxnId(data),
      walletBalance: extractWalletBalance(data),
    );
    if (orderResult.walletBalance != null) {
      wallet.setCachedBalance(orderResult.walletBalance!);
    }
    placeOrderState = UiSuccess(orderResult);
    notifyListeners();
    return orderResult;
  }

  Future<CheckoutOrderResult?> _placeOrder({
    required CartController cart,
    required CheckoutAddressFields address,
    required List<Map<String, dynamic>> products,
    required String paymentMethod,
    required double payable,
    required Future<ApiResult<Map<String, dynamic>>> Function() orderApiCall,
    Future<void> Function()? onFailure,
  }) async {
    placeOrderState = const UiLoading();
    notifyListeners();

    final cartCheckout = await cart.checkoutCart(
      firstName: address['firstName']!,
      lastName: address['lastName']!,
      email: address['email']!,
      phone: address['phone']!,
      state: address['state']!,
      city: address['city']!,
      address: address['address']!,
      pincode: address['pincode']!,
      landmark: address['landmark']!,
      addressType: address['addressType']!,
      paymentMethod: paymentMethod,
      amount: payable,
    );

    ApiResult<Map<String, dynamic>> result;
    if (cartCheckout is ApiSuccess<Map<String, dynamic>>) {
      result = cartCheckout;
    } else {
      result = await orderApiCall();
    }

    if (result is ApiFailure<Map<String, dynamic>>) {
      placeOrderState = UiError(result.message);
      notifyListeners();
      await onFailure?.call();
      return null;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final orderResult = CheckoutOrderResult(
      orderId: extractOrderId(data) ?? '',
      txnId: extractTxnId(data),
      paymentUrl: extractPaymentUrl(data),
      walletBalance: extractWalletBalance(data),
    );
    placeOrderState = UiSuccess(orderResult);
    notifyListeners();
    return orderResult;
  }
}
