import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import 'app_motion.dart';

/// Coordinates bottom-nav tab index + cart icon / sticky bar targets.
///
/// Tab order: 0 Home · 1 Categories · 2 Cart · 3 Orders · 4 Account
class ShellController extends ChangeNotifier {
  static const int homeTab = 0;
  static const int categoriesTab = 1;
  static const int cartTab = 2;
  static const int ordersTab = 3;
  static const int accountTab = 4;

  int tabIndex = 0;
  final GlobalKey cartIconKey = GlobalKey(debugLabel: 'cart_nav_icon');
  final GlobalKey stickyCartKey = GlobalKey(debugLabel: 'sticky_cart_bar');

  /// Bumped whenever Home (or elsewhere) requests Categories with a filter.
  int categoriesIntentSeq = 0;
  String? pendingCategoryId;
  String? pendingBrowseQuery;

  void goToTab(int index) {
    if (tabIndex == index) return;
    tabIndex = index;
    notifyListeners();
  }

  /// Opens the Categories tab, optionally pre-filtered.
  /// Pass [categoryId] `'all'` (default) for the unfiltered catalog.
  void goToCategories({String? categoryId, String? query}) {
    pendingCategoryId = categoryId ?? 'all';
    pendingBrowseQuery = query ?? '';
    categoriesIntentSeq++;
    tabIndex = categoriesTab;
    notifyListeners();
  }

  void clearCategoriesIntent() {
    pendingCategoryId = null;
    pendingBrowseQuery = null;
  }

  void goToHome() => goToTab(homeTab);
  void goToCart() => goToTab(cartTab);
  void goToOrders() => goToTab(ordersTab);
  void goToAccount() => goToTab(accountTab);

  Offset? cartIconGlobalCenter() {
    final sticky = stickyCartKey.currentContext?.findRenderObject() as RenderBox?;
    if (sticky != null && sticky.hasSize) {
      return sticky.localToGlobal(sticky.size.center(Offset.zero));
    }
    final box = cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

Future<void> playFlyToCart({
  required BuildContext context,
  required Offset from,
  required ShellController shell,
  Color color = AppColors.success,
  Widget? flyingChild,
}) async {
  final overlay = Overlay.of(context);
  final to = shell.cartIconGlobalCenter() ??
      Offset(
        MediaQuery.sizeOf(context).width * 0.5,
        MediaQuery.sizeOf(context).height - 100,
      );

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FlyParticle(
      from: from,
      to: to,
      color: color,
      child: flyingChild,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
  await Future<void>.delayed(AppMotion.fly);
}

class _FlyParticle extends StatefulWidget {
  const _FlyParticle({
    required this.from,
    required this.to,
    required this.color,
    required this.onDone,
    this.child,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final VoidCallback onDone;
  final Widget? child;

  @override
  State<_FlyParticle> createState() => _FlyParticleState();
}

class _FlyParticleState extends State<_FlyParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: AppMotion.fly);
    _t = CurvedAnimation(parent: _c, curve: AppMotion.flyCurve);
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        final t = _t.value;
        final mid = Offset(
          (widget.from.dx + widget.to.dx) / 2,
          math.min(widget.from.dy, widget.to.dy) - 140,
        );
        final pos = Offset(
          _quad(widget.from.dx, mid.dx, widget.to.dx, t),
          _quad(widget.from.dy, mid.dy, widget.to.dy, t),
        );
        final scale = lerpDouble(1.0, 0.2, t)!;
        final opacity = lerpDouble(1.0, 0.0, Curves.easeIn.transform(t))!;
        return Positioned(
          left: pos.dx - 18,
          top: pos.dy - 18,
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              child: widget.child ??
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft(color: widget.color, opacity: 0.35),
                    ),
                    child: const Icon(Icons.shopping_bag, size: 16, color: Colors.white),
                  ),
            ),
          ),
        );
      },
    );
  }

  double _quad(double a, double b, double c, double t) {
    final u = 1 - t;
    return u * u * a + 2 * u * t * b + t * t * c;
  }
}
