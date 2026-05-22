import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11),
          unselectedItemColor: Colors.grey.shade400,
          selectedItemColor: const Color(0xFF019934),
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
