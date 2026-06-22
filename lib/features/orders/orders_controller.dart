import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';
import 'package:urban_roots/features/orders/order_payment_utils.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_tracking_models.dart';
import 'package:urban_roots/features/userProfile/user_profile_controller.dart';
import 'package:urban_roots/features/userProfile/address_controller.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';

class OrderPaymentResult {
  const OrderPaymentResult._({
    required this.success,
    this.message = '',
    this.paymentUrl,
    this.txnId,
  });

  final bool success;
  final String message;
  final String? paymentUrl;
  final String? txnId;

  factory OrderPaymentResult.success({
    required String message,
    String? paymentUrl,
    String? txnId,
  }) =>
      OrderPaymentResult._(
        success: true,
        message: message,
        paymentUrl: paymentUrl,
        txnId: txnId,
      );

  factory OrderPaymentResult.failure(String message) =>
      OrderPaymentResult._(success: false, message: message);
}

class TrackingFetchResult<T> {
  const TrackingFetchResult({this.data, this.userMessage});

  final T? data;
  final String? userMessage;
}

String _friendlyTrackingMessage(String? technical) {
  if (technical == null || technical.trim().isEmpty) {
    return 'Unable to load tracking updates right now. Please try again.';
  }
  final lower = technical.toLowerCase();
  if (lower.contains('non-json') ||
      lower.contains('html') ||
      lower.contains('server error')) {
    return 'Unable to load tracking updates right now. Please try again.';
  }
  return technical;
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

  /// Keeps order history in sync when detail API returns fresher data.
  void upsertOrder(Order order) {
    final index = orders.indexWhere(
      (existing) =>
          (order.orderId > 0 && existing.orderId == order.orderId) ||
          (order.txnId.isNotEmpty && existing.txnId == order.txnId),
    );
    if (index >= 0) {
      orders[index] = order;
    }
  }

  Future<Order?> loadOrderDetail({int? orderId, String? txnId}) async {
    final hasTxn = txnId != null && txnId.trim().isNotEmpty;
    final hasOrderId = orderId != null && orderId > 0;
    if (!hasTxn && !hasOrderId) {
      errorMessage.value = 'Missing order reference';
      return null;
    }

    final result = await _api.orders.orderDetail(
      orderId: hasTxn ? null : (hasOrderId ? orderId.toString() : null),
      txnId: hasTxn ? txnId.trim() : null,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      return null;
    }
    return parseOrderDetail((result as ApiSuccess<Map<String, dynamic>>).data);
  }

  Future<TrackingFetchResult<OrderTrackingData>> loadOrderTracking({
    int? orderId,
    String? txnId,
  }) async {
    final hasTxn = txnId != null && txnId.trim().isNotEmpty;
    final hasOrderId = orderId != null && orderId > 0;
    if (!hasTxn && !hasOrderId) {
      return const TrackingFetchResult(
        userMessage: 'Missing order reference for tracking',
      );
    }

    final result = await _api.orders.trackOrder(
      txnId: hasTxn ? txnId.trim() : null,
      orderId: hasOrderId ? orderId.toString() : null,
    );
    if (result is ApiFailure<Map<String, dynamic>>) {
      return TrackingFetchResult(
        userMessage: _friendlyTrackingMessage(result.message),
      );
    }

    final parsed = parseOrderTracking(
      (result as ApiSuccess<Map<String, dynamic>>).data,
    );
    if (parsed == null) {
      return const TrackingFetchResult(
        userMessage: 'No tracking updates are available yet.',
      );
    }
    return TrackingFetchResult(data: parsed);
  }

  Future<TrackingFetchResult<OrderLiveTrackingData>> loadLiveTracking({
    required int orderId,
  }) async {
    if (orderId <= 0) {
      return const TrackingFetchResult();
    }

    final result = await _api.orders.liveTracking(orderId: orderId.toString());
    if (result is ApiFailure<Map<String, dynamic>>) {
      return const TrackingFetchResult();
    }

    final parsed = parseLiveTracking(
      (result as ApiSuccess<Map<String, dynamic>>).data,
    );
    return TrackingFetchResult(data: parsed);
  }

  Future<bool> verifyOrderPayment({int? orderId, String? txnId}) async {
    final order = await loadOrderDetail(orderId: orderId, txnId: txnId);
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
    final paymentUrl = extractPaymentUrl(data);
    final resolvedUrl = (paymentUrl != null && paymentUrl.isNotEmpty)
        ? paymentUrl
        : order.pendingPaymentUrl;
    if (resolvedUrl.isEmpty) {
      return OrderPaymentResult.failure(
        'Could not start online payment for this order.',
      );
    }

    return OrderPaymentResult.success(
      message: data['message']?.toString() ?? 'Continue to payment',
      paymentUrl: resolvedUrl,
      txnId: extractTxnId(data),
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
