/// App-wide configuration and API environment.
class AppConfig {
  AppConfig._();

  /// When `true`, repositories serve mock data (no network).
  /// When `false`, repositories call Dio / [ApiEndpoints].
  static const bool kDemoMode = false;

  static const String kApiBaseUrl = 'https://veggiicart.com/public/api/v1';

  /// Prefix only — full header is `'$kAuthHeaderPrefix$accessToken'`.
  static const String kAuthHeaderPrefix = 'Bearer ';

  static const int kAccessTokenTtlSeconds = 3600; // 1 hour
  static const int kRefreshTokenTtlSeconds = 2592000; // 30 days

  static String get apiBaseUrl => kApiBaseUrl;

  static const String appName = 'VeggiiCart';
  static const String companySlug = 'virtuousglobal';
}
