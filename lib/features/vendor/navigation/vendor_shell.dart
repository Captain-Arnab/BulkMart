import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_dashboard_controller.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_earnings_controller.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_orders_controller.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_profile_controller.dart';
import 'package:urban_roots/features/vendor/dashboard/vendor_dashboard_screen.dart';
import 'package:urban_roots/features/vendor/earnings/vendor_earnings_screen.dart';
import 'package:urban_roots/features/vendor/orders/vendor_orders_screen.dart';
import 'package:urban_roots/features/vendor/products/vendor_products_screen.dart';
import 'package:urban_roots/features/vendor/profile/vendor_profile_screen.dart';

/// Vendor bottom navigation — isolated from user app flow.
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  static void Function(int index)? switchTab;

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _selectedIndex = 0;
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    Get.put(VendorDashboardController());
    Get.put(VendorProductsController());
    Get.put(VendorOrdersController());
    Get.put(VendorEarningsController());
    Get.put(VendorProfileController());
    VendorShell.switchTab = _selectTab;
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
    _loadTabIfNeeded(index);
  }

  void _loadTabIfNeeded(int index) {
    if (!_visitedTabs.add(index)) return;
    switch (index) {
      case 1:
        Get.find<VendorProductsController>().loadProducts();
      case 2:
        Get.find<VendorOrdersController>().loadOrders();
      case 3:
        Get.find<VendorEarningsController>().load();
      case 4:
        Get.find<VendorProfileController>().load();
    }
  }

  @override
  void dispose() {
    VendorShell.switchTab = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          VendorDashboardScreen(),
          VendorProductsScreen(),
          VendorOrdersScreen(),
          VendorEarningsScreen(),
          VendorProfileScreen(),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
