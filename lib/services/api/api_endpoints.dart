/// Central endpoint paths — never hardcode URLs in widgets or ViewModels.
/// Base URL lives on [AppConfig.apiBaseUrl] / [ApiClient].
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth (public except logout which is optional-bearer) ──
  static const String sendOtp = '/auth/send-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String emailLogin = '/auth/email-login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ── Business / KYC (JWT) ──
  static const String businessTypes = '/business-types';
  static const String businessRegister = '/business/register';
  static const String businessDocuments = '/business/documents';
  static const String businessResubmit = '/business/resubmit';
  static const String businessVerificationStatus =
      '/business/verification-status';

  // ── Profile (JWT) ──
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';

  // ── Catalog (public) ──
  static const String products = '/products';
  static const String categories = '/categories';
  static String categoryDetail(String id) => '/categories/$id';
  static String productDetail(String id) => '/products/$id';
  static const String productSearch = '/products/search';
  static const String banners = '/banners';
  static const String offers = '/offers';

  // ── Cart (JWT) ──
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String id) => '/cart/items/$id';
  static const String cartCoupon = '/cart/coupon';

  // ── Orders (JWT) ──
  static const String placeOrder = '/orders';
  static const String orders = '/orders';
  static const String deliverySlots = '/delivery-slots';
  static String orderDetail(String id) => '/orders/$id';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderInvoice(String id) => '/orders/$id/invoice';
  static String orderReorder(String id) => '/orders/$id/reorder';

  // ── Addresses (JWT) ──
  static const String addresses = '/addresses';
  static String addressDetail(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';

  // ── Wishlist (JWT) ──
  static const String wishlist = '/wishlist';
  static String wishlistItem(String id) => '/wishlist/$id';
  static String wishlistMoveToCart(String id) => '/wishlist/$id/move-to-cart';

  // ── Notifications (JWT) ──
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ── Support ──
  static const String supportFaqs = '/support/faqs';
  static const String supportTickets = '/support/tickets';
  static String supportTicketDetail(String id) => '/support/tickets/$id';

  /// Paths that must NOT receive an Authorization header.
  static bool isPublicPath(String path) {
    final p = path.split('?').first;
    if (p == sendOtp ||
        p == resendOtp ||
        p == verifyOtp ||
        p == emailLogin ||
        p == refreshToken ||
        p == businessTypes ||
        p == categories ||
        p == products ||
        p == productSearch ||
        p == banners ||
        p == offers ||
        p == supportFaqs) {
      return true;
    }
    if (p.startsWith('/categories/')) return true;
    if (p.startsWith('/products/')) return true;
    return false;
  }
}
