import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/notifications/push_notification_service.dart';
import 'package:flutter/foundation.dart';

/// Call after successful login or when restoring an existing session.
Future<void> syncDeviceTokenAfterAuth({required AuthRole role}) async {
  final result = await PushNotificationService.instance
      .registerTokenWithBackendIfLoggedIn(role: role);
  if (kDebugMode) {
    debugPrint('[DeviceToken] post-auth sync: ${result.message}');
  }
}
