import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class SupportApiService {
  SupportApiService({ApiClient? client}) : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> createTicket({
    required String subject,
    required String message,
    String? orderId,
  }) =>
      _client.post(
        APIClass.supportTickets,
        body: {
          'subject': subject,
          'message': message,
          if (orderId != null) 'order_id': orderId,
        },
      );

  Future<ApiResult<Map<String, dynamic>>> referral() =>
      _client.get(APIClass.referral);
}
