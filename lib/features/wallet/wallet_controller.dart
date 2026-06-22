import 'dart:convert';

import 'package:get/get.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class WalletController extends GetxController {
  final _api = UrbanRootsApi.instance;

  final RxDouble balance = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;

  Future<void> loadBalance() async {
    isLoading(true);
    final result = await _api.wallet.balance();
    isLoading(false);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      _applyBalanceFromResponse(result.data);
    } else if (result is ApiFailure<Map<String, dynamic>>) {
      errorMessage.value = result.message;
    }
  }

  void setCachedBalance(double value) {
    balance.value = value;
  }

  void _applyBalanceFromResponse(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is Map) {
      balance.value =
          double.tryParse(data['balance']?.toString() ?? '0') ?? 0;
    }
  }

  Future<void> loadTransactions({int page = 1}) async {
    final result = await _api.wallet.transactions(page: page);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      currentPage.value = page;
      final list = extractList(result.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (page == 1) {
        transactions.assignAll(list);
      } else {
        transactions.addAll(list);
      }
    }
  }

  Future<ApiResult<Map<String, dynamic>>> initiateTopUp(double amount) async {
    return _api.wallet.topUpInitiate(amount: amount);
  }

  Future<ApiResult<String>> verifyTopUp(String txnId) async {
    return _api.wallet.topUpVerify(txnId: txnId);
  }

  /// Verifies wallet top-up with backend and refreshes balance on success.
  Future<bool> completeTopUpVerification(String txnId) async {
    if (txnId.isEmpty) return false;

    final result = await verifyTopUp(txnId);
    if (result is ApiFailure<String>) {
      errorMessage.value = result.message;
      return false;
    }

    final raw = (result as ApiSuccess<String>).data.trim();
    final text = raw.toLowerCase();

    var verified = text.contains('success') ||
        text.contains('verified') ||
        text.contains('complete') ||
        text.contains('paid');

    if (!verified && text.startsWith('{')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          verified = ApiStatus.fromMap(map) == true;
        }
      } catch (_) {}
    }

    if (verified) {
      await loadBalance();
      await loadTransactions();
    }

    return verified;
  }

  static WalletController findOrPut() {
    if (Get.isRegistered<WalletController>()) {
      return Get.find<WalletController>();
    }
    return Get.put(WalletController());
  }

  @override
  void onInit() {
    super.onInit();
    loadBalance();
    loadTransactions();
  }
}
