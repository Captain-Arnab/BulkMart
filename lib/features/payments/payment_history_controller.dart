import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class PaymentHistoryController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadPayments() async {
    isLoading(true);
    errorMessage.value = '';

    final walletResult = await _api.wallet.transactions(page: 1);
    final ordersResult = await _api.orders.listOrders();

    isLoading(false);

    final walletOk = walletResult is ApiSuccess<Map<String, dynamic>>;
    final ordersOk = ordersResult is ApiSuccess<Map<String, dynamic>>;

    if (!walletOk && !ordersOk) {
      final walletMsg = walletResult is ApiFailure<Map<String, dynamic>>
          ? walletResult.message
          : '';
      final ordersMsg = ordersResult is ApiFailure<Map<String, dynamic>>
          ? ordersResult.message
          : '';
      errorMessage.value = ordersMsg.isNotEmpty ? ordersMsg : walletMsg;
      payments.clear();
      return;
    }

    final walletRecords = walletResult is ApiSuccess<Map<String, dynamic>>
        ? parseWalletTransactions(walletResult.data)
        : <Map<String, dynamic>>[];

    final orderRecords = ordersResult is ApiSuccess<Map<String, dynamic>>
        ? paymentRecordsFromOrders(parseOrders(ordersResult.data))
        : <Map<String, dynamic>>[];

    payments.assignAll(mergePaymentRecords(walletRecords, orderRecords));
  }

  static PaymentHistoryController findOrPut() {
    if (Get.isRegistered<PaymentHistoryController>()) {
      return Get.find<PaymentHistoryController>();
    }
    return Get.put(PaymentHistoryController());
  }
}
