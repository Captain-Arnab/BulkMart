/// API base URL configuration.
///
/// User API  : {root}/api/user
/// Vendor API: {root}/api/vendor
class ApiConfig {
  ApiConfig._();

  static const String apiKey = 'URBANROOTS_API_2026';

  static const String defaultSiteRoot = 'https://urbunroots.com';

  static const String productionSiteRoot = String.fromEnvironment(
    'PRODUCTION_API_BASE_URL',
    defaultValue: '',
  );

  static const String stagingSiteRoot = String.fromEnvironment(
    'STAGING_API_BASE_URL',
    defaultValue: '',
  );

  static const String legacySiteRoot = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get siteRoot {
    if (productionSiteRoot.isNotEmpty) return _stripApiSuffix(productionSiteRoot);
    if (stagingSiteRoot.isNotEmpty) return _stripApiSuffix(stagingSiteRoot);
    if (legacySiteRoot.isNotEmpty) return _stripApiSuffix(legacySiteRoot);
    return defaultSiteRoot;
  }

  static String get userBaseUrl => '$siteRoot/api/user';

  static String get vendorBaseUrl => '$siteRoot/api/vendor';

  /// Legacy alias — returns site root.
  static String get baseUrl => siteRoot;

  static bool get isApiConfigured => siteRoot.isNotEmpty;

  static String get environmentLabel {
    if (productionSiteRoot.isNotEmpty) return 'production';
    if (stagingSiteRoot.isNotEmpty) return 'staging';
    if (legacySiteRoot.isNotEmpty) return 'custom';
    return 'default';
  }

  static String _stripApiSuffix(String url) {
    var root = url;
    if (root.endsWith('/')) root = root.substring(0, root.length - 1);
    if (root.endsWith('/api/user')) return root.substring(0, root.length - 9);
    if (root.endsWith('/api/vendor')) return root.substring(0, root.length - 11);
    return root;
  }
}
