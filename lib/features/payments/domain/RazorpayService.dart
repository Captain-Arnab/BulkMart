import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class RazorpayService {
  final _api = UrbanRootsApi.instance;

  Future<List<dynamic>> fetchPaymentHistory() async {
    final result = await _api.wallet.transactions(page: 1);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      return parseWalletTransactions(result.data);
    }
    return [];
  }
}
