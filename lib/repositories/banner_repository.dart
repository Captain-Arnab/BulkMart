import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../models/home_banner.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class BannerRepository {
  factory BannerRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) return MockBannerRepository();
    return ApiBannerRepository(apiClient: apiClient!);
  }

  Future<Result<List<HomeBanner>>> getActive();
}

class MockBannerRepository implements BannerRepository {
  @override
  Future<Result<List<HomeBanner>>> getActive() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const Success([
      HomeBanner(
        id: 'demo_1',
        title: 'Fresh Produce. Better Every Day.',
        imageUrl: 'https://picsum.photos/seed/veggiicart-banner-1/800/400',
        sortOrder: 1,
      ),
    ]);
  }
}

class ApiBannerRepository implements BannerRepository {
  ApiBannerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<HomeBanner>>> getActive() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.banners);
      if (kDebugMode) {
        debugPrint('[BannerRepository] GET ${ApiEndpoints.banners} '
            'status=${response.statusCode}');
      }
      final parsed = ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['banners'] is List
            ? data['banners'] as List
            : data is List
                ? data
                : const [];
        final banners = raw
            .map((e) => HomeBanner.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((b) => b.hasImage)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (kDebugMode) {
          debugPrint('[BannerRepository] parsed ${banners.length} banner(s)');
        }
        return banners;
      });
      return parsed.when(
        success: (list) => Success(list),
        failure: (message, {statusCode, code, fields}) {
          if (kDebugMode) {
            debugPrint('[BannerRepository] envelope failure: $message');
          }
          return Failure(
            message,
            statusCode: statusCode,
            code: code,
            fields: fields,
          );
        },
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BannerRepository] request failed: $e\n$st');
      }
      return ApiEnvelope.fromDio(e);
    }
  }
}
