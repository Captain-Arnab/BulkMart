import 'package:flutter/material.dart';

import '../ui/app_motion.dart';

/// App-wide fade-through / soft-slide page route (150–250ms).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    this.slide = true,
  }) : super(
          settings: settings,
          transitionDuration: AppMotion.page,
          reverseTransitionDuration: AppMotion.fast,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: AppMotion.ease);
            if (!slide) {
              return FadeTransition(opacity: curved, child: child);
            }
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );

  final bool slide;

  static Future<T?> push<T>(BuildContext context, Widget page, {bool slide = true}) {
    return Navigator.of(context).push<T>(
      AppPageRoute<T>(builder: (_) => page, slide: slide),
    );
  }

  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page, {
    bool slide = true,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      AppPageRoute<T>(builder: (_) => page, slide: slide),
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page, {
    bool slide = true,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      AppPageRoute<T>(builder: (_) => page, slide: slide),
      (_) => false,
    );
  }
}
