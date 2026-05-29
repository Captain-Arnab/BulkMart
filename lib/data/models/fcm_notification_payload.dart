import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

/// Parsed FCM payload — notification (title/body) + data fields from backend.
class FcmNotificationPayload {
  const FcmNotificationPayload({
    this.title,
    this.body,
    this.type,
    this.role,
    this.orderId,
    this.status,
    this.clickAction,
    this.rawData = const {},
  });

  final String? title;
  final String? body;
  final String? type;
  final AuthRole? role;
  final String? orderId;
  final String? status;
  final String? clickAction;
  final Map<String, dynamic> rawData;

  factory FcmNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return FcmNotificationPayload(
      title: message.notification?.title ?? data['title'] as String?,
      body: message.notification?.body ?? data['body'] as String?,
      type: data['type'] as String?,
      role: AuthRole.fromApi(data['role'] as String?),
      orderId: data['order_id'] as String?,
      status: data['status'] as String?,
      clickAction: data['click_action'] as String?,
      rawData: Map<String, dynamic>.from(data),
    );
  }

  bool isForRole(AuthRole currentRole) {
    if (role == null) return true;
    return role == currentRole;
  }
}
