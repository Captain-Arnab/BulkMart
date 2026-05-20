import 'package:get/get.dart';
import 'package:urban_roots/data/dummy_data.dart';

class WalletController extends GetxController {
  final RxDouble balance = DummyData.walletBalance.obs;
  final RxList<Map<String, dynamic>> transactions =
      DummyData.walletTransactions.obs;

  void addTopUp(double amount) {
    balance.value += amount;
    transactions.insert(0, {
      'id': 'WTX${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Wallet Top-up',
      'amount': amount,
      'type': 'credit',
      'date': DateTime.now().toString().substring(0, 10),
      'method': 'PhonePe UPI',
    });
    DummyData.walletBalance = balance.value;
  }

  void deduct(double amount, String title) {
    if (balance.value < amount) return;
    balance.value -= amount;
    transactions.insert(0, {
      'id': 'WTX${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'amount': amount,
      'type': 'debit',
      'date': DateTime.now().toString().substring(0, 10),
      'method': 'Wallet',
    });
    DummyData.walletBalance = balance.value;
  }
}
