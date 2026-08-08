import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../widgets/sticky_cart_bar.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../catalog/category_browse_screen.dart';
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
    _TabSpec('Products', Icons.grid_view_outlined, Icons.grid_view_rounded),
    _TabSpec('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
    _TabSpec('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _TabSpec('Account', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  static const int _cartTabIndex = ShellController.cartTab;

  /// Lazily mount tabs so secondary tabs don't init until first open.
  final Set<int> _activated = {0};

  static const double _navHeight = 64;
  static const double _navHMargin = 12;
  static const double _navBottomGap = 10;
  static const double _navRadius = 26;

  @override
  Widget build(BuildContext context) {
    final index = context.select<ShellController, int>((s) => s.tabIndex);
    final cartCount = context.select<CartViewModel, int>((c) => c.itemCount);
    final shell = context.read<ShellController>();
    _activated.add(index);

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final navBottom = _navBottomGap + bottomInset;

    return Scaffold(
      backgroundColor: AppColors.section,
      // No Scaffold.bottomNavigationBar — that slot paints a full-width Material
      // strip behind the child and makes a floating pill look edge-to-edge.
      body: Stack(
        children: [
          Positioned.fill(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.paddingOf(context).copyWith(
                  top: MediaQuery.viewPaddingOf(context).top,
                  bottom: navBottom + _navHeight + 8,
                ),
              ),
              child: IndexedStack(
                index: index,
                children: [
                  const HomeScreen(),
                  _activated.contains(1)
                      ? const CategoryBrowseScreen(asTab: true)
                      : const SizedBox.shrink(),
                  _activated.contains(2) ? const CartScreen() : const SizedBox.shrink(),
                  _activated.contains(3) ? const OrdersScreen() : const SizedBox.shrink(),
                  _activated.contains(4) ? const AccountScreen() : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: navBottom + _navHeight + 4,
            child: KeyedSubtree(
              key: shell.stickyCartKey,
              child: const StickyCartBar(bottomInset: 0),
            ),
          ),
          Positioned(
            left: _navHMargin,
            right: _navHMargin,
            bottom: navBottom,
            height: _navHeight,
            child: _FloatingPillNav(
              tabs: _tabs,
              index: index,
              cartTabIndex: _cartTabIndex,
              cartCount: cartCount,
              cartIconKey: shell.cartIconKey,
              onSelect: shell.goToTab,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPillNav extends StatelessWidget {
  const _FloatingPillNav({
    required this.tabs,
    required this.index,
    required this.cartTabIndex,
    required this.cartCount,
    required this.cartIconKey,
    required this.onSelect,
  });

  final List<_TabSpec> tabs;
  final int index;
  final int cartTabIndex;
  final int cartCount;
  final GlobalKey cartIconKey;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_MainShellState._navRadius),
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_MainShellState._navRadius),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabW = constraints.maxWidth / tabs.length;
            // Tighter inset for 5 tabs so the green pill still reads clearly.
            const hPad = 4.0;
            const vPad = 6.0;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: AppMotion.ease,
                  left: tabW * index + hPad,
                  top: vPad,
                  bottom: vPad,
                  width: tabW - (hPad * 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: PressableScale(
                          scale: 0.94,
                          onTap: () => onSelect(i),
                          child: SizedBox(
                            height: constraints.maxHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    KeyedSubtree(
                                      key: i == cartTabIndex ? cartIconKey : null,
                                      child: Icon(
                                        index == i ? tabs[i].activeIcon : tabs[i].icon,
                                        size: 20,
                                        color: index == i
                                            ? AppColors.white
                                            : AppColors.muted,
                                      ),
                                    ),
                                    if (i == cartTabIndex && cartCount > 0)
                                      Positioned(
                                        right: -10,
                                        top: -6,
                                        child: _CartCountBadge(count: cartCount),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  tabs[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body(
                                    fontSize: 9,
                                    fontWeight: index == i
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: index == i
                                        ? AppColors.white
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}

class _CartCountBadge extends StatelessWidget {
  const _CartCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 1.35, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: AppMotion.pop,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        constraints: const BoxConstraints(minWidth: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.white, width: 1.5),
          boxShadow: AppShadows.soft(opacity: 0.12),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          textAlign: TextAlign.center,
          style: AppTextStyles.price(
            fontSize: 9,
            color: AppColors.ink,
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
