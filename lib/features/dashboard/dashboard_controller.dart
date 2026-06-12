import 'package:get/get.dart';

/// Which main area of the app shell is visible.
enum DashboardRoute {
  home,
  products,
  wishlist,
  cart,
  profile,
  paymentHistory,
  orderHistory,
  addresses,
}

/// Simple tab + sub-screen navigation for the main shell (replaces Dashboard BLoC).
class DashboardController extends GetxController {
  final route = DashboardRoute.home.obs;

  void goToTab(int index) {
    switch (index) {
      case 0:
        route.value = DashboardRoute.home;
      case 1:
        route.value = DashboardRoute.products;
      case 2:
        route.value = DashboardRoute.wishlist;
      case 3:
        route.value = DashboardRoute.cart;
      case 4:
        route.value = DashboardRoute.profile;
      default:
        route.value = DashboardRoute.home;
    }
  }

  int get currentTabIndex {
    switch (route.value) {
      case DashboardRoute.home:
        return 0;
      case DashboardRoute.products:
        return 1;
      case DashboardRoute.wishlist:
        return 2;
      case DashboardRoute.cart:
        return 3;
      case DashboardRoute.profile:
      case DashboardRoute.paymentHistory:
      case DashboardRoute.orderHistory:
      case DashboardRoute.addresses:
        return 4;
    }
  }

  void openPaymentHistory() => route.value = DashboardRoute.paymentHistory;
  void openOrderHistory() => route.value = DashboardRoute.orderHistory;
  void openAddresses() => route.value = DashboardRoute.addresses;
  void backToProfile() => route.value = DashboardRoute.profile;

  static DashboardController findOrPut() {
    if (Get.isRegistered<DashboardController>()) {
      return Get.find<DashboardController>();
    }
    return Get.put(DashboardController(), permanent: true);
  }
}
