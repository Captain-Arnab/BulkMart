/// Central endpoint paths — never hardcode URLs in widgets or ViewModels.
/// Base URL lives on [ApiClient]. Paths here are relative.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // Catalog
  static const String products = '/products';
  static const String categories = '/categories';
  static String productDetail(String id) => '/products/$id';
  static const String productSearch = '/products/search';

  // Cart / Orders
  static const String cart = '/cart';
  static const String placeOrder = '/orders';
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';

  // Account
  static const String addresses = '/addresses';
}
