import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_roots/Utils/APIClass.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/config/api_config.dart';
import 'package:urban_roots/data/models/device_token_register_result.dart';
import 'package:urban_roots/data/network/vendor_api_service.dart';

/// Sends FCM device tokens to Urban Roots backend.
class DeviceTokenRepository {
  DeviceTokenRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      AuthInterceptor(() => AuthSession.instance.getToken()),
    );
  }

  final Dio _dio;

  Future<DeviceTokenRegisterResult> registerDeviceToken({
    required String deviceToken,
    required AuthRole role,
  }) async {
    if (!ApiConfig.isApiConfigured) {
      if (kDebugMode) {
        debugPrint(
          '[DeviceToken] API_BASE_URL not set — token ready for backend: '
          '${deviceToken.substring(0, deviceToken.length.clamp(0, 24))}... role=${role.apiValue}',
        );
      }
      return DeviceTokenRegisterResult.skipped(
        'API base URL not configured (set --dart-define=API_BASE_URL=...)',
      );
    }

    try {
      final response = await _dio.post(
        APIClass.registerDeviceToken,
        data: {
          'device_token': deviceToken,
          'platform': Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'ios'
                  : 'unknown',
          'role': role.apiValue,
          'package_name': _androidPackageName,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return DeviceTokenRegisterResult.success('Device token registered');
      }
      return DeviceTokenRegisterResult.failed(
        'Server returned ${response.statusCode}',
      );
    } on DioException catch (e) {
      return DeviceTokenRegisterResult.failed(
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    }
  }

  Future<void> unregisterDeviceToken({required String deviceToken}) async {
    if (!ApiConfig.isApiConfigured) return;

    try {
      await _dio.delete(
        APIClass.unregisterDeviceToken,
        data: {'device_token': deviceToken},
      );
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[DeviceToken] unregister failed: $e');
    }
  }

  /// Android applicationId (same binary for customer + vendor flows).
  static const String _androidPackageName = 'com.urbanroots.delivery';
}
