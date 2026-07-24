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
}
