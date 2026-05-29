import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/config/firebase_config.dart';
import 'package:urban_roots/core/notifications/fcm_notification_router.dart';
import 'package:urban_roots/data/models/device_token_register_result.dart';
import 'package:urban_roots/data/repositories/device_token_repository.dart';

/// Top-level handler for background FCM messages (required by firebase_messaging).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FcmNotificationRouter.instance.handleMessage(
    message,
    source: 'background',
  );
}

/// FCM setup: permissions, token fetch, refresh, backend registration, role-aware routing.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceTokenRepository _deviceTokenRepository = DeviceTokenRepository();

  bool _initialized = false;
  String? _cachedToken;

  Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      FcmNotificationRouter.instance.handleMessage(message, source: 'foreground');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      FcmNotificationRouter.instance.handleMessage(message, source: 'opened_app');
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await FcmNotificationRouter.instance.handleMessage(
        initialMessage,
        source: 'terminated_launch',
      );
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      _cachedToken = newToken;
      await registerTokenWithBackendIfLoggedIn(fcmToken: newToken);
    });

    if (kDebugMode) {
      debugPrint(
        '[FCM] Initialized | project=${FirebaseConfig.projectId} '
        'package=${FirebaseConfig.androidPackageName}',
      );
    }

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      await _messaging.requestPermission();
    }
  }

  Future<String?> getFcmToken() async {
    try {
      _cachedToken ??= await _messaging.getToken();
      return _cachedToken;
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] getToken failed: $e');
      return null;
    }
  }

  /// Registers FCM token with backend Device Token API (JWT + role: user | vendor).
  Future<DeviceTokenRegisterResult> registerTokenWithBackendIfLoggedIn({
    String? fcmToken,
    AuthRole? role,
  }) async {
    final loggedIn = await AuthSession.instance.isLoggedIn();
    if (!loggedIn) {
      return DeviceTokenRegisterResult.skipped('Not logged in');
    }

    final token = fcmToken ?? await getFcmToken();
    if (token == null || token.isEmpty) {
      return DeviceTokenRegisterResult.failed('FCM token unavailable');
    }

    final resolvedRole = role ?? await AuthSession.instance.getRole();
    if (resolvedRole == null) {
      return DeviceTokenRegisterResult.failed('User role unknown');
    }

    var result = await _deviceTokenRepository.registerDeviceToken(
      deviceToken: token,
      role: resolvedRole,
    );

    // One retry on transient failure when API is configured.
    if (!result.success && !result.skipped) {
      await Future.delayed(const Duration(seconds: 2));
      result = await _deviceTokenRepository.registerDeviceToken(
        deviceToken: token,
        role: resolvedRole,
      );
    }

    if (kDebugMode) {
      debugPrint('[FCM] Device token sync: ${result.message} role=${resolvedRole.apiValue}');
    }

    return result;
  }

  Future<void> unregisterFromBackend() async {
    final token = _cachedToken ?? await getFcmToken();
    if (token != null) {
      await _deviceTokenRepository.unregisterDeviceToken(deviceToken: token);
    }
    try {
      await _messaging.deleteToken();
      _cachedToken = null;
    } catch (_) {}
  }
}
