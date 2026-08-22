/// App-wide configuration and API environment.
///
/// Pick API host with `--dart-define=API_ENV=prod` or `API_ENV=local`.
/// Default is `local` during the live-API integration pass so JWT works
/// against XAMPP; flip to `prod` for store builds.
class AppConfig {
  AppConfig._();

  /// When `true`, repositories serve mock data (no network).
  /// When `false`, repositories call Dio / [ApiEndpoints].
  static const bool kDemoMode = false;

  /// `local` | `prod` — from `--dart-define=API_ENV=...`
  static const String kApiEnv =
      String.fromEnvironment('API_ENV', defaultValue: 'local');

  static const String kApiBaseUrlProd =
      'https://veggiicart.com/public/api/v1';
  static const String kApiBaseUrlLocal =
      'http://localhost/VGS/veggiicart/public/api/v1';

  /// Prefix only — full header is `'$kAuthHeaderPrefix$accessToken'`.
  static const String kAuthHeaderPrefix = 'Bearer ';

  static const int kAccessTokenTtlSeconds = 3600; // 1 hour
  static const int kRefreshTokenTtlSeconds = 2592000; // 30 days

  static bool get useLocalApi => kApiEnv.toLowerCase() == 'local';

  static String get apiBaseUrl =>
      useLocalApi ? kApiBaseUrlLocal : kApiBaseUrlProd;

  static const String appName = 'VeggiiCart';
  static const String companySlug = 'virtuousglobal';
}
