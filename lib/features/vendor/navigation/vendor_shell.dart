import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/vendor/dashboard/vendor_dashboard_screen.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_products_navigator.dart';
import 'package:urban_roots/features/vendor/orders/orders_placeholder_screen.dart';
import 'package:urban_roots/features/vendor/profile/vendor_profile_screen.dart';

/// Vendor bottom navigation shell (equivalent to VendorNavGraph).
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _selectedIndex = 0;

  final _productNavKey = GlobalKey<NavigatorState>();

  void _onTabSelected(int index) {
    if (index == 1 && _selectedIndex != 1) {
      _productNavKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const VendorDashboardScreen(),
          VendorProductsNavigator(navigatorKey: _productNavKey),
          const OrdersPlaceholderScreen(),
          const VendorProfileScreen(),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.dashboard_rounded : Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.inventory_2_rounded : Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Icons.receipt_long_rounded : Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3 ? Icons.person_rounded : Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
