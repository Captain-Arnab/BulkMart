/// API base URL — override at build time: --dart-define=API_BASE_URL=https://your-api.com
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get isApiConfigured => baseUrl.isNotEmpty;
}
