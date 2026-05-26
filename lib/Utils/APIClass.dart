import 'package:urban_roots/core/config/api_config.dart';

class APIClass {
  static String get baseUrl => ApiConfig.baseUrl;

  // Auth
  static const userLogin = '/api/auth/login';
  static const vendorLogin = '/api/vendor/login';

  // Push notifications — device token registration
  static const registerDeviceToken = '/api/device-token';
  static const unregisterDeviceToken = '/api/device-token';

  // Catalog / profile (placeholders for live API)
  static const userRegister = '/api/auth/register';
  static const products = '/api/products';
  static const getProfile = '/api/profile';
}
