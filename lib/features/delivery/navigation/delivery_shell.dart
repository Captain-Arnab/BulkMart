import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/delivery/dashboard/delivery_dashboard_screen.dart';
import 'package:urban_roots/features/delivery/work_log/delivery_work_log_screen.dart';

/// Delivery boy bottom navigation — isolated from user/vendor flows.
class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DeliveryDashboardScreen(),
          DeliveryWorkLogScreen(),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'Work Log',
          ),
        ],
      ),
    );
  }
}
