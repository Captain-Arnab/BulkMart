import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/notifications/push_notification_service.dart';
import 'package:flutter/foundation.dart';

/// Call after successful login or when restoring an existing session.
/// Failures are logged only — never shown to the user or used to log out.
Future<void> syncDeviceTokenAfterAuth({required AuthRole role}) async {
  try {
    final result = await PushNotificationService.instance
        .registerTokenWithBackendIfLoggedIn(role: role);
    if (kDebugMode) {
      if (result.success) {
        debugPrint('[DeviceToken] post-auth sync: ${result.message}');
      } else if (!result.skipped) {
        debugPrint('[API_ERROR] post-auth device sync: ${result.message}');
      }
    }
  } catch (e) {
    debugPrint('[API_ERROR] post-auth device sync exception: $e');
  }
}
