import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/orders/domain/order_payment_utils.dart';
import 'package:urban_roots/features/orders/models/order_model.dart';
import 'package:urban_roots/features/userProfile/domain/UserProfileController.dart';
import 'package:urban_roots/features/userProfile/domain/address_controller.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

class OrderPaymentResult {
  const OrderPaymentResult._({
    required this.success,
    this.message = '',
    this.paymentUrl,
  });

  final bool success;
  final String message;
  final String? paymentUrl;

  factory OrderPaymentResult.success({
    required String message,
    String? paymentUrl,
  }) =>
      OrderPaymentResult._(
        success: true,
        message: message,
        paymentUrl: paymentUrl,
      );

  factory OrderPaymentResult.failure(String message) =>
      OrderPaymentResult._(success: false, message: message);
}

class OrdersController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.orders.listOrders();
    isLoading(false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      orders.clear();
      return;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    orders.assignAll(parseOrders(data));
  }

  Future<Order?> loadOrderDetail(int orderId) async {
    final result = await _api.orders.orderDetail(orderId: orderId.toString());
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return null;
    }
    return parseOrderDetail((result as ApiSuccess<Map<String, dynamic>>).data);
  }

  Future<bool> verifyOrderPayment(int orderId) async {
    final order = await loadOrderDetail(orderId);
    return order?.isPaymentComplete ?? false;
  }

  Future<OrderPaymentFields> _resolvePaymentFields(Order order) async {
    Map<String, dynamic>? profile;
    try {
      profile = await UserProfileController().fetchUserData();
    } catch (_) {}

    Address? defaultAddress;
    final addressController = AddressController.findOrPut();
    if (addressController.addresses.isEmpty) {
      await addressController.loadAddresses();
    }
    for (final address in addressController.addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }
    defaultAddress ??=
        addressController.addresses.isNotEmpty ? addressController.addresses.first : null;

    return buildOrderPaymentFields(
      order: order,
      profile: profile,
      defaultAddress: defaultAddress,
    );
  }

  Future<OrderPaymentResult> payOrderOnline(Order order) async {
    final fields = await _resolvePaymentFields(order);
    if (!fields.isComplete) {
      return OrderPaymentResult.failure(
        'Missing ${fields.missingFields.join(', ')}. Please add a delivery address in your profile and try again.',
      );
    }

    final result = await _api.orders.retryOnlinePayment(fields: fields);

    if (result is ApiFailure<Map<String, dynamic>>) {
      return OrderPaymentResult.failure(result.message);
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    final paymentUrl =
        extractPaymentUrl(data) ?? order.pendingPaymentUrl;
    if (paymentUrl == null || paymentUrl.isEmpty) {
      return OrderPaymentResult.failure(
        'Could not start online payment for this order.',
      );
    }

    return OrderPaymentResult.success(
      message: data['message']?.toString() ?? 'Continue to payment',
      paymentUrl: paymentUrl,
    );
  }

  Future<OrderPaymentResult> payOrderOnDelivery(Order order) async {
    final fields = await _resolvePaymentFields(order);
    if (!fields.isComplete) {
      return OrderPaymentResult.failure(
        'Missing ${fields.missingFields.join(', ')}. Please add a delivery address in your profile and try again.',
      );
    }

    final result = await _api.orders.switchOrderToCod(fields: fields);

    if (result is ApiFailure<Map<String, dynamic>>) {
      return OrderPaymentResult.failure(result.message);
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    await loadOrders();
    return OrderPaymentResult.success(
      message: data['message']?.toString() ??
          'Order updated to Cash on Delivery',
    );
  }

  static OrdersController findOrPut() {
    if (Get.isRegistered<OrdersController>()) {
      return Get.find<OrdersController>();
    }
    return Get.put(OrdersController());
  }
}
