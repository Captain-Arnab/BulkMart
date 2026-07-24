/// Endpoint paths relative to User or Vendor API base URL.
/// User base  : https://urbunroots.com/api/user
/// Vendor base: https://urbunroots.com/api/vendor
class APIClass {
  APIClass._();

  // ── MODULE 1 — AUTH (user base) ──────────────────────────────────
  static const userSignup = '/signup.php';
  static const userLogin = '/login.php';
  static const userLogout = '/logout.php';
  static const changePassword = '/change_password.php';
  static const forgotPassword = '/forgot_password.php';
  static const otpLogin = '/otp-login.php';
  static const sendLoginOtp = '/send-login-otp.php';
  static const socialLogin = '/social-login.php';

  // ── MODULE 2 — PROFILE (user base) ───────────────────────────────
  static const getProfile = '/get_profile.php';
  static const updateProfile = '/update_profile.php';
  static const editAddress = '/edit_address.php';

  // ── MODULE 3 — ADDRESS (user base) ───────────────────────────────
  static const getAddresses = '/get_addresses.php';
  static const addAddress = '/add_address.php';
  static const deleteAddress = '/delete_address.php';
  static const setDefaultAddress = '/set_default_address.php';

  // ── MODULE 4 — CATALOG (user base) ───────────────────────────────
  static const listCategories = '/list-categories.php';
  static const getProducts = '/get-product.php';
  static const getByCategory = '/get_by_category.php';
  static const productView = '/product-view.php';
  static const searchProducts = '/search.php';
  static const homeBanners = '/home-banners.php';
  static const homeProducts = '/home/products.php';
  static const vendorsList = '/vendors/list.php';
  static const checkPincode = '/check_pincode.php';
  static const removePincode = '/remove_pincode.php';

  static String vendorProducts(String vendorId) =>
      '/vendors/$vendorId/products.php';

  // ── MODULE 5 — CART (user base) ──────────────────────────────────
  static const cartAdd = '/cart/add.php';
  static const cartGet = '/cart/get.php';
  static const cartUpdate = '/cart/update.php';
  static const cartRemove = '/cart/remove.php';
  static const cartClear = '/cart/clear.php';
  static const cartCheckout = '/cart/checkout.php';

  // ── MODULE 6 — WISHLIST (user base) ──────────────────────────────
  static const wishlistAdd = '/wishlist/add.php';
  static const wishlistList = '/wishlist/list.php';
  static const wishlistCount = '/wishlist/count.php';
  static const wishlistCheck = '/wishlist/check.php';
  static const wishlistRemove = '/wishlist/remove.php';

  // ── MODULE 7 — COUPONS (user base) ───────────────────────────────
  static const couponsList = '/coupons/list.php';
  static const couponsApply = '/coupons/apply.php';
  static const couponsRemove = '/coupons/remove.php';

  // ── MODULE 8 — ORDERS (user base) ────────────────────────────────
  static const codOrder = '/orders/cod_order.php';
  static const onlineOrder = '/orders/paywith_online_order.php';
  static const walletOrder = '/orders/wallet_order.php';
  static const buyNow = '/orders/buy_now.php';
  static const ordersList = '/orders/list.php';
  static const orderDetail = '/orders/detail.php';
  static const orderTracking = '/orders/tracking.php';
  static const cancelOrder = '/orders/cancel.php';
  static const liveTracking = '/orders/live-tracking.php';

  // ── MODULE 9 — WALLET (user base) ──────────────────────────────────
  static const walletAdd = '/wallet/add.php';
  static const walletVerify = '/wallet/verify.php';
  static const walletBalance = '/wallet/balance.php';
  static const walletDeduct = '/wallet/deduct.php';
  static const walletTransactions = '/wallet/transactions.php';

  // ── MODULE 9b — PAYMENTS & SAVED CARDS (user base) ─────────────────
  static const paymentsHistory = '/payments/history.php';
  /// Confirms PhonePe status for order / wallet / SUB_-prefixed txns.
  static const paymentsCheckStatus = '/payments/check-status.php';
  static const cardsSave = '/cards/save.php';
  static const cardsConfirm = '/cards/confirm.php';
  static const cardsList = '/cards/list.php';
  static const cardsDelete = '/cards/delete.php';

  // ── MODULE 10 — SUBSCRIPTION (user base) ─────────────────────────
  static const subscriptionPlans = '/subscription/plans.php';
  static const subscriptionCreate = '/subscription/create.php';
  static const subscriptionStatus = '/subscription/status.php';

  // ── MODULE 11 — REVIEWS (user base) ────────────────────────────────
  static const reviewsList = '/reviews/list.php';
  static const reviewsAdd = '/reviews/add.php';
  static const vendorReviewsList = '/reviews/vendor-list.php';

  // ── MODULE 12 — NOTIFICATIONS (user base) ──────────────────────────
  static const notificationsList = '/notifications/list.php';
  static const notificationsMarkRead = '/notifications/mark_read.php';
  static const registerDevice = '/notifications/register-device.php';

  // ── MODULE 13 — SUPPORT & REFERRAL (user base) ─────────────────────
  static const supportTickets = '/support/tickets.php';
  static const supportCreate = '/support/create.php';
  static const referral = '/referral.php';

  // ── OFFERS (site base: /api) ─────────────────────────────────────
  static const offersList = '/offers/list.php';

  // ── MODULE 14 — VENDOR AUTH ────────────────────────────────────────
  /// Registration OTP — user base
  static const vendorSendOtp = '/vendor/send-otp.php';
  static const vendorVerifyOtp = '/vendor/verify-otp.php';
  /// Login — vendor base
  static const vendorLogin = '/login.php';

  // ── MODULE 15 — VENDOR PANEL (vendor base) ─────────────────────────
  static const vendorDashboard = '/dashboard.php';
  static const vendorAddCategory = '/add_category.php';
  static const vendorProductsList = '/products/list.php';
  static const vendorAddProduct = '/add_vendor_product.php';
  static const vendorUpdateProduct = '/products/update.php';
  static const vendorDeleteProduct = '/products/delete.php';
  static const vendorOrdersList = '/orders/list.php';
  static const vendorOrderStatus = '/orders/status.php';
  static const vendorAvailability = '/availability.php';
  static const vendorEarnings = '/earnings.php';
  static const vendorProfile = '/profile.php';
  static const vendorAnalytics = '/analytics.php';
  static const vendorPayoutHistory = '/payouts/history.php';
  static const vendorRaiseTicket = '/support/raise-ticket.php';
  static const vendorSupportTickets = '/support/tickets.php';

  // ── MODULE 16 — DELIVERY BOY (delivery_boy_api base) ───────────────
  static const deliveryClock = '/clock.php';
  static const deliveryWorkLog = '/work-log.php';

  // ── MODULE 17 — ADMIN (admin base, no token) ───────────────────────
  static const adminVendorPayoutReport = '/vendor-payout-report.php';
  static const adminVendorSalesSummary = '/vendor-sales-summary.php';
  static const adminDeliveryMonitoring = '/delivery-monitoring.php';
  static const adminDeliveryAttendance = '/delivery-attendance.php';
}
