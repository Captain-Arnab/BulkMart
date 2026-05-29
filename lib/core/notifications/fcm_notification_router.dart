import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/data/models/fcm_notification_payload.dart';

/// Routes incoming FCM messages — filters by role (`user` / `vendor`) when set.
class FcmNotificationRouter {
  FcmNotificationRouter._();
  static final FcmNotificationRouter instance = FcmNotificationRouter._();

  /// Last notification opened from tray (for deep-link wiring later).
  FcmNotificationPayload? pendingPayload;

  Future<void> handleMessage(
    RemoteMessage message, {
    required String source,
  }) async {
    final payload = FcmNotificationPayload.fromRemoteMessage(message);
    final sessionRole = await AuthSession.instance.getRole();

    if (payload.role != null && sessionRole != null && !payload.isForRole(sessionRole)) {
      if (kDebugMode) {
        debugPrint(
          '[FCM] Ignored ($source): role=${payload.role?.apiValue} '
          'session=${sessionRole.apiValue}',
        );
      }
      return;
    }

    pendingPayload = payload;

    if (kDebugMode) {
      debugPrint(
        '[FCM] $source | title=${payload.title} type=${payload.type} '
        'role=${payload.role?.apiValue ?? "any"} action=${payload.clickAction}',
      );
    }

    // Deep-link navigation (order detail, etc.) — wire when order APIs are live.
    _routeByClickAction(payload, sessionRole);
  }

  void _routeByClickAction(FcmNotificationPayload payload, AuthRole? sessionRole) {
    switch (payload.clickAction) {
      case 'ORDER_DETAIL':
      case 'order_status':
        if (kDebugMode && payload.orderId != null) {
          debugPrint('[FCM] Order notification: id=${payload.orderId} status=${payload.status}');
        }
        break;
      default:
        break;
    }
  }

  void clearPending() => pendingPayload = null;
}
