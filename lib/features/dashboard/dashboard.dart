import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/cart/cart_screen.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/dashboard/wishlist_screen.dart';
import 'package:urban_roots/features/orders/order_history_screen.dart';
import 'package:urban_roots/features/payments/payment_history_screen.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';
import 'package:urban_roots/features/home/presentation/home_screen.dart';
import 'package:urban_roots/features/subscription/subscription_flow_controller.dart';
import 'package:urban_roots/features/subscription/presentation/subscription_products_screen.dart';
import 'package:urban_roots/features/userProfile/presentation/AddressListScreen.dart';
import 'package:urban_roots/features/userProfile/presentation/TestProfile.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = DashboardController.findOrPut();

    return Obx(() {
      final route = nav.route.value;

      return Scaffold(
        body: _buildBody(route),
        bottomNavigationBar: ModernBottomNav(
          currentIndex: nav.currentTabIndex,
          onTap: nav.goToTab,
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(
                nav.currentTabIndex == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Products',
              icon: Icon(
                nav.currentTabIndex == 1
                    ? Icons.grid_view_rounded
                    : Icons.grid_view_outlined,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Wishlist',
              icon: Icon(
                nav.currentTabIndex == 2
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Cart',
              icon: Icon(
                nav.currentTabIndex == 3
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_cart_outlined,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(
                nav.currentTabIndex == 4
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody(DashboardRoute route) {
    switch (route) {
      case DashboardRoute.home:
        return const HomeScreen();
      case DashboardRoute.products:
        final flow = SubscriptionFlowController.findOrPut();
        if (flow.hasActivePlan) {
          return const SubscriptionProductsScreen();
        }
        return const ProductPage(category: 0, minPrice: 0, maxPrice: 10000);
      case DashboardRoute.wishlist:
        return const WishListPage();
      case DashboardRoute.cart:
        return const CartPage();
      case DashboardRoute.profile:
        return UserProfileScreen();
      case DashboardRoute.paymentHistory:
        return const PaymentHistoryScreen();
      case DashboardRoute.orderHistory:
        return const OrderHistory();
      case DashboardRoute.addresses:
        return AddressListScreen();
    }
  }
}
