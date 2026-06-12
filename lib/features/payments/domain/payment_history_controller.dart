import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class PaymentHistoryController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    isLoading(true);
    errorMessage.value = '';
    final result = await _api.wallet.transactions(page: 1);
    isLoading(false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
      payments.clear();
      return;
    }

    final data = (result as ApiSuccess<Map<String, dynamic>>).data;
    payments.assignAll(parseWalletTransactions(data));
  }

  static PaymentHistoryController findOrPut() {
    if (Get.isRegistered<PaymentHistoryController>()) {
      return Get.find<PaymentHistoryController>();
    }
    return Get.put(PaymentHistoryController());
  }
}
