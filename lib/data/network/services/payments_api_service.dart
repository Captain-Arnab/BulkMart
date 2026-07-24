import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class PaymentsApiService {
  PaymentsApiService({
    ApiClient? client,
    ApiClient? rootClient,
  })  : _client = client ?? ApiClient.user,
        _root = rootClient ?? ApiClient.root;

  final ApiClient _client;
  final ApiClient _root;

  /// GET /payments/history.php
  /// [type] optional: `wallet_topup` | `order_payment`
  Future<ApiResult<Map<String, dynamic>>> history({
    int page = 1,
    int limit = 20,
    String? type,
  }) {
    final capped = limit.clamp(1, 50);
    return _client.get(
      APIClass.paymentsHistory,
      queryParameters: {
        'page': page,
        'limit': capped,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
  }

  /// POST|GET `/check-status.php` on site root (not under /api/).
  /// Auth not required. Routes by txn prefix: SUB_ / WALLET_ / other.
  ///
  /// Prefer POST form-urlencoded `transactionId` (JSON body will not work).
  Future<ApiResult<Map<String, dynamic>>> checkStatus({
    required String transactionId,
  }) {
    final txn = transactionId.trim();
    if (txn.isEmpty) {
      return Future.value(
        const ApiFailure('Missing transactionId for payment check'),
      );
    }
    return _root.postFormUrlEncoded(
      APIClass.checkStatus,
      fields: {'transactionId': txn},
      token: TokenMode.none,
    );
  }
}
