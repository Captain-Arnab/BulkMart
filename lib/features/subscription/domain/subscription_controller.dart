import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class SubscriptionController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Map<String, dynamic>> plans = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> activeSubscription = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = false.obs;
  final RxBool isSubscribing = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading(true);
    errorMessage.value = '';
    await Future.wait([loadPlans(), loadStatus()]);
    isLoading(false);
  }

  Future<void> loadPlans() async {
    final result = await _api.subscription.listPlans();
    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      plans.clear();
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    plans.assignAll(parseSubscriptionPlans(data));
  }

  Future<void> loadStatus() async {
    final result = await _api.subscription.status();
    if (result is ApiFailure<Map<String, dynamic>>) {
      return;
    }
    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    activeSubscription.value = parseSubscriptionStatus(data);
  }

  Future<SubscriptionCreateResult> subscribe(Map<String, dynamic> plan) async {
    isSubscribing(true);
    try {
      final planId = plan['id']?.toString() ?? '';
      final productId = plan['product_id']?.toString() ?? '0';
      final startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final result = await _api.subscription.create(
        planId: planId,
        productId: productId,
        startDate: startDate,
      );

      if (result is ApiFailure<Map<String, dynamic>>) {
        return SubscriptionCreateResult.failure(result.message);
      }

      final data = (result as ApiSuccess<Map<String, dynamic>>).data;
      final redirect = _extractPaymentUrl(data);
      await loadStatus();

      return SubscriptionCreateResult.success(
        message: data['message']?.toString() ?? 'Subscription created successfully',
        paymentUrl: redirect,
      );
    } finally {
      isSubscribing(false);
    }
  }

  String? _extractPaymentUrl(Map<String, dynamic> data) {
    for (final key in ['redirect_url', 'payment_url', 'pay_url']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    final inner = data['data'];
    if (inner is Map) {
      for (final key in ['redirect_url', 'payment_url', 'pay_url']) {
        final value = inner[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}

class SubscriptionCreateResult {
  const SubscriptionCreateResult._({
    required this.success,
    this.message = '',
    this.paymentUrl,
  });

  final bool success;
  final String message;
  final String? paymentUrl;

  factory SubscriptionCreateResult.success({
    required String message,
    String? paymentUrl,
  }) =>
      SubscriptionCreateResult._(
        success: true,
        message: message,
        paymentUrl: paymentUrl,
      );

  factory SubscriptionCreateResult.failure(String message) =>
      SubscriptionCreateResult._(success: false, message: message);
}
