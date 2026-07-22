import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/data/repositories/order_repository.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';

class BuyNowResult {
  const BuyNowResult({
    required this.orderId,
    this.txnId,
    this.paymentUrl,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
  });

  final String orderId;
  final String? txnId;
  final String? paymentUrl;
  final double? totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
}

/// Places a single-product order via [OrderRepository.buyNow].
class BuyNowViewModel extends ChangeNotifier {
  BuyNowViewModel({
    OrderRepository? repository,
    UrbanRootsApi? api,
  })  : _repository = repository ?? ApiOrderRepository(),
        _api = api ?? UrbanRootsApi.instance;

  final OrderRepository _repository;
  final UrbanRootsApi _api;

  UiState<BuyNowResult>? submitState;

  bool get isSubmitting => submitState is UiLoading;

  void resetSubmitState() {
    submitState = null;
    notifyListeners();
  }

  /// [paymentMethodUi] is the checkout UI value (`cod` / `online`).
  /// The API receives uppercase `COD` / `ONLINE`.
  Future<BuyNowResult?> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String landmark,
    required String addressType,
    required String productId,
    required int quantity,
    required String paymentMethodUi,
  }) async {
    submitState = const UiLoading();
    notifyListeners();

    final apiPaymentMethod =
        paymentMethodUi.toLowerCase() == 'online' ? 'ONLINE' : 'COD';

    final result = await _repository.buyNow(
      firstName: firstName,
      phone: phone,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      landmark: landmark,
      addressType: addressType,
      productId: productId,
      quantity: quantity,
      paymentMethod: apiPaymentMethod,
    );

    if (result is ApiFailure<Map<String, dynamic>>) {
      submitState = UiError(result.message);
      notifyListeners();
      return null;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    var orderResult = BuyNowResult(
      orderId: extractOrderId(data) ?? '',
      txnId: extractTxnId(data),
      paymentUrl: extractPaymentUrl(data),
      totalAmount: extractTotalAmount(data),
      paymentMethod: data['payment_method']?.toString() ??
          data['paymentMethod']?.toString(),
      paymentStatus: data['payment_status']?.toString() ??
          data['paymentStatus']?.toString(),
    );

    // buy_now.php may create the ONLINE order without a redirect URL.
    // Fall back to the existing PhonePe initiation endpoint used by cart checkout.
    if (apiPaymentMethod == 'ONLINE' &&
        (orderResult.paymentUrl == null || orderResult.paymentUrl!.isEmpty) &&
        orderResult.orderId.isNotEmpty) {
      final paymentInit = await _api.orders.placeOnlineOrder(
        firstName: firstName,
        lastName: lastName.isNotEmpty ? lastName : firstName,
        email: email,
        phone: phone,
        state: state,
        city: city,
        address: address,
        pincode: pincode,
        landmark: landmark,
        addressType: addressType,
        products: [
          {'product_id': productId, 'quantity': quantity},
        ],
        orderId: orderResult.orderId,
      );

      if (paymentInit is ApiSuccess<Map<String, dynamic>>) {
        final payData = paymentInit.data;
        orderResult = BuyNowResult(
          orderId: extractOrderId(payData) ?? orderResult.orderId,
          txnId: extractTxnId(payData) ?? orderResult.txnId,
          paymentUrl: extractPaymentUrl(payData),
          totalAmount: extractTotalAmount(payData) ?? orderResult.totalAmount,
          paymentMethod: orderResult.paymentMethod,
          paymentStatus: orderResult.paymentStatus,
        );
      }
    }

    submitState = UiSuccess(orderResult);
    notifyListeners();
    return orderResult;
  }
}
