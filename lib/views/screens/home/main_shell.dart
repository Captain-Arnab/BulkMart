import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../widgets/sticky_cart_bar.dart';
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
  static const _tabs = [
    _TabSpec('Home', Icons.home_outlined, Icons.home_rounded),
    _TabSpec('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
    _TabSpec('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _TabSpec('Account', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  /// Lazily mount tabs so Cart / Orders / Account don't init until first open.
  final Set<int> _activated = {0};

  @override
  Widget build(BuildContext context) {
    final index = context.select<ShellController, int>((s) => s.tabIndex);
    final cartCount = context.select<CartViewModel, int>((c) => c.itemCount);
    final shell = context.read<ShellController>();
    _activated.add(index);

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    const navHeight = 64.0;
    const navGap = 12.0;

    return Scaffold(
      backgroundColor: AppColors.section,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.paddingOf(context).copyWith(
                  top: MediaQuery.viewPaddingOf(context).top,
                ),
              ),
              child: IndexedStack(
                index: index,
                children: [
                  const HomeScreen(),
                  _activated.contains(1) ? const CartScreen() : const SizedBox.shrink(),
                  _activated.contains(2) ? const OrdersScreen() : const SizedBox.shrink(),
                  _activated.contains(3) ? const AccountScreen() : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: navHeight + navGap + bottomInset + 8,
            child: KeyedSubtree(
              key: shell.stickyCartKey,
              child: const StickyCartBar(bottomInset: 0),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, navGap + bottomInset),
        child: Container(
          height: navHeight,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.floating,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabW = constraints.maxWidth / _tabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: AppMotion.pop,
                    left: tabW * index + 8,
                    top: 8,
                    bottom: 8,
                    width: tabW - 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            onTap: () => shell.goToTab(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    KeyedSubtree(
                                      key: i == 1 ? shell.cartIconKey : null,
                                      child: Icon(
                                        index == i ? _tabs[i].activeIcon : _tabs[i].icon,
                                        size: 22,
                                        color: index == i ? AppColors.white : AppColors.muted,
                                      ),
                                    ),
                                    if (i == 1 && cartCount > 0)
                                      Positioned(
                                        right: -10,
                                        top: -6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            cartCount > 99 ? '99+' : '$cartCount',
                                            key: ValueKey(cartCount),
                                            style: AppTextStyles.price(
                                              fontSize: 9,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _tabs[i].label,
                                  style: AppTextStyles.body(
                                    fontSize: 10,
                                    fontWeight:
                                        index == i ? FontWeight.w700 : FontWeight.w500,
                                    color: index == i ? AppColors.white : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
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
