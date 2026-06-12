import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/data/network/api_result.dart';

class NotificationsApiService {
  NotificationsApiService({ApiClient? client})
      : _client = client ?? ApiClient.user;
  final ApiClient _client;

  Future<ApiResult<Map<String, dynamic>>> list() =>
      _client.get(APIClass.notificationsList);

  Future<ApiResult<Map<String, dynamic>>> markRead({
    required String notificationId,
  }) =>
      _client.post(
        APIClass.notificationsMarkRead,
        body: {'notification_id': notificationId},
      );

  Future<ApiResult<Map<String, dynamic>>> registerDevice({
    required String fcmToken,
    String platform = 'android',
  }) =>
      _client.post(
        APIClass.registerDevice,
        body: {'fcm_token': fcmToken, 'platform': platform},
        skipSessionClear: true,
      );
}
