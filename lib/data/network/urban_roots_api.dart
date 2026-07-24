import 'package:urban_roots/data/network/services/address_api_service.dart';
import 'package:urban_roots/data/network/services/auth_api_service.dart';
import 'package:urban_roots/data/network/services/cards_api_service.dart';
import 'package:urban_roots/data/network/services/cart_api_service.dart';
import 'package:urban_roots/data/network/services/catalog_api_service.dart';
import 'package:urban_roots/data/network/services/coupons_api_service.dart';
import 'package:urban_roots/data/network/services/notifications_api_service.dart';
import 'package:urban_roots/data/network/services/offers_api_service.dart';
import 'package:urban_roots/data/network/services/orders_api_service.dart';
import 'package:urban_roots/data/network/services/payments_api_service.dart';
import 'package:urban_roots/data/network/services/profile_api_service.dart';
import 'package:urban_roots/data/network/services/reviews_api_service.dart';
import 'package:urban_roots/data/network/services/subscription_api_service.dart';
import 'package:urban_roots/data/network/services/support_api_service.dart';
import 'package:urban_roots/data/network/services/vendor_panel_api_service.dart';
import 'package:urban_roots/data/network/services/wallet_api_service.dart';
import 'package:urban_roots/data/network/services/wishlist_api_service.dart';

/// Facade exposing all Urban Roots API module services.
class UrbanRootsApi {
  UrbanRootsApi._();

  static final UrbanRootsApi instance = UrbanRootsApi._();

  final auth = AuthApiService();
  final profile = ProfileApiService();
  final address = AddressApiService();
  final catalog = CatalogApiService();
  final cart = CartApiService();
  final wishlist = WishlistApiService();
  final coupons = CouponsApiService();
  final offers = OffersApiService();
  final orders = OrdersApiService();
  final wallet = WalletApiService();
  final payments = PaymentsApiService();
  final cards = CardsApiService();
  final subscription = SubscriptionApiService();
  final reviews = ReviewsApiService();
  final notifications = NotificationsApiService();
  final support = SupportApiService();
  final vendorAuth = VendorAuthApiService();
  final vendorPanel = VendorPanelApiService();
}
