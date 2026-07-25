/// App-wide configuration. Flip [kDemoMode] to `false` when live APIs are ready.
class AppConfig {
  AppConfig._();

  /// When `true`, repositories serve mock data (no network).
  /// When `false`, repositories call Dio / [ApiEndpoints].
  static const bool kDemoMode = true;

  static const String appName = 'BulkMart';
  static const String companySlug = 'virtuousglobal';
}
