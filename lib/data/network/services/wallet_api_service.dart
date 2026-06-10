import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class WalletApiService {
  WalletApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> topUpInitiate({
    required double amount,
  }) =>
      _client.post(
        APIClass.walletAdd,
        body: {'amount': amount},
      );

  Future<ApiResult<String>> topUpVerify({required String txnId}) =>
      _client.getPlain(
        APIClass.walletVerify,
        queryParameters: {'txn': txnId},
      );

  Future<ApiResult<Map<String, dynamic>>> balance() =>
      _client.get(APIClass.walletBalance);

  Future<ApiResult<Map<String, dynamic>>> deduct({
    required double amount,
    required String orderId,
  }) =>
      _client.post(
        APIClass.walletDeduct,
        body: {'amount': amount, 'order_id': orderId},
      );

  Future<ApiResult<Map<String, dynamic>>> transactions({
    required int page,
  }) =>
      _client.get(
        APIClass.walletTransactions,
        queryParameters: {'page': page},
      );
}
