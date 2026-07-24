import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class PaymentsApiService {
  PaymentsApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

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

  /// GET /payments/check-status.php
  /// Confirms final payment_status for order / wallet / SUB_-prefixed txns.
  Future<ApiResult<Map<String, dynamic>>> checkStatus({
    String? orderId,
    String? txnId,
  }) {
    final params = <String, dynamic>{};
    if (orderId != null && orderId.isNotEmpty) {
      params['order_id'] = orderId;
    }
    if (txnId != null && txnId.isNotEmpty) {
      params['txn_id'] = txnId;
      params['txn'] = txnId;
    }
    return _client.get(
      APIClass.paymentsCheckStatus,
      queryParameters: params,
    );
  }
}
