import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _TabSpec('HOME', Icons.home_outlined, Icons.home),
    _TabSpec('CART', Icons.shopping_bag_outlined, Icons.shopping_bag),
    _TabSpec('ORDERS', Icons.receipt_long_outlined, Icons.receipt_long),
    _TabSpec('ACCOUNT', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartViewModel>().itemCount;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CartScreen(),
          OrdersScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _index = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                _index == i ? _tabs[i].activeIcon : _tabs[i].icon,
                                size: 22,
                                color: _index == i ? AppColors.forest : AppColors.slate,
                              ),
                              if (i == 1 && cartCount > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.rust,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      cartCount > 99 ? '99+' : '$cartCount',
                                      style: AppTextStyles.mono(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[i].label,
                            style: AppTextStyles.mono(
                              fontSize: 9.5,
                              fontWeight: _index == i ? FontWeight.w700 : FontWeight.w400,
                              color: _index == i ? AppColors.forest : AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
