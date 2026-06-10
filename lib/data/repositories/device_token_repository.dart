import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/data/models/device_token_register_result.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

/// Registers FCM tokens via POST /api/user/notifications/register-device.php
class DeviceTokenRepository {
  DeviceTokenRepository({UrbanRootsApi? api})
      : _api = api ?? UrbanRootsApi.instance;

  final UrbanRootsApi _api;

  Future<DeviceTokenRegisterResult> registerDeviceToken({
    required String deviceToken,
    required AuthRole role,
  }) async {
    if (role == AuthRole.vendor) {
      if (kDebugMode) {
        debugPrint(
          '[DeviceToken] Vendor FCM registration uses user endpoint when '
          'vendor panel adds dedicated support.',
        );
      }
    }

    try {
      final result = await _api.notifications.registerDevice(
        fcmToken: deviceToken,
        platform: _platform,
      );

      if (result is ApiSuccess<Map<String, dynamic>>) {
        return DeviceTokenRegisterResult.success('Device token registered');
      }
      final failure = result as ApiFailure<Map<String, dynamic>>;
      return DeviceTokenRegisterResult.failed(failure.message);
    } catch (e) {
      return DeviceTokenRegisterResult.failed(e.toString());
    }
  }

  /// No dedicated unregister endpoint in contract — clear handled on logout.
  Future<void> unregisterDeviceToken({required String deviceToken}) async {
    if (kDebugMode) {
      debugPrint('[DeviceToken] unregister skipped — no contract endpoint');
    }
  }

  String get _platform => Platform.isAndroid
      ? 'android'
      : Platform.isIOS
          ? 'ios'
          : 'unknown';
}
