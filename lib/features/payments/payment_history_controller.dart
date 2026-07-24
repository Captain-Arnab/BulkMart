import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/payment_repository.dart';

/// Filter values map to the `type` query param on payments/history.php.
enum PaymentHistoryFilter { all, walletTopup, orderPayment }

extension PaymentHistoryFilterX on PaymentHistoryFilter {
  String? get apiType {
    switch (this) {
      case PaymentHistoryFilter.all:
        return null;
      case PaymentHistoryFilter.walletTopup:
        return 'wallet_topup';
      case PaymentHistoryFilter.orderPayment:
        return 'order_payment';
    }
  }

  String get label {
    switch (this) {
      case PaymentHistoryFilter.all:
        return 'All';
      case PaymentHistoryFilter.walletTopup:
        return 'Wallet Top-ups';
      case PaymentHistoryFilter.orderPayment:
        return 'Order Payments';
    }
  }
}

class PaymentHistoryController extends GetxController {
  PaymentHistoryController({PaymentRepository? repository})
      : _repository = repository ?? ApiPaymentRepository();

  final PaymentRepository _repository;
  static const int _pageSize = 20;

  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<PaymentHistoryFilter> filter = PaymentHistoryFilter.all.obs;

  int _page = 1;

  Future<void> loadPayments({bool refresh = true}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      isLoading(true);
      errorMessage.value = '';
    } else {
      if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
      isLoadingMore(true);
    }

    final result = await _repository.getPaymentHistory(
      page: _page,
      limit: _pageSize,
      type: filter.value.apiType,
    );

    if (refresh) {
      isLoading(false);
    } else {
      isLoadingMore(false);
    }

    if (result is ApiFailure<PaymentHistoryPage>) {
      if (refresh) {
        errorMessage.value = result.message;
        payments.clear();
      }
      return;
    }

    final page = (result as ApiSuccess<PaymentHistoryPage>).data;
    if (refresh) {
      payments.assignAll(page.payments);
    } else {
      payments.addAll(page.payments);
    }
    hasMore.value = page.hasMore;
    if (page.hasMore) _page = page.page + 1;
  }

  Future<void> loadMore() => loadPayments(refresh: false);

  Future<void> setFilter(PaymentHistoryFilter value) async {
    if (filter.value == value) return;
    filter.value = value;
    await loadPayments();
  }

  static PaymentHistoryController findOrPut() {
    if (Get.isRegistered<PaymentHistoryController>()) {
      return Get.find<PaymentHistoryController>();
    }
    return Get.put(PaymentHistoryController());
  }
}
