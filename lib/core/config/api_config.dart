/// API base URL configuration.
///
/// Priority: production → staging → legacy `API_BASE_URL`.
/// Backend will share production URL after live-server verification.
///
/// ```bash
/// # Staging (when shared)
/// flutter run --dart-define=STAGING_API_BASE_URL=https://staging-api.example.com
///
/// # Production (when verified)
/// flutter run --dart-define=PRODUCTION_API_BASE_URL=https://api.example.com
/// ```
class ApiConfig {
  ApiConfig._();

  static const String productionBaseUrl = String.fromEnvironment(
    'PRODUCTION_API_BASE_URL',
    defaultValue: '',
  );

  static const String stagingBaseUrl = String.fromEnvironment(
    'STAGING_API_BASE_URL',
    defaultValue: '',
  );

  /// Legacy single-URL flag (still supported).
  static const String legacyBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (productionBaseUrl.isNotEmpty) return productionBaseUrl;
    if (stagingBaseUrl.isNotEmpty) return stagingBaseUrl;
    return legacyBaseUrl;
  }

  static bool get isApiConfigured => baseUrl.isNotEmpty;

  static String get environmentLabel {
    if (productionBaseUrl.isNotEmpty) return 'production';
    if (stagingBaseUrl.isNotEmpty) return 'staging';
    if (legacyBaseUrl.isNotEmpty) return 'custom';
    return 'unset';
  }
}
