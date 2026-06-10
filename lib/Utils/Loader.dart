import 'package:flutter/material.dart';

class Loader {
  /// Shows a non-dismissible loading overlay. Always pair with [hide].
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: Image.asset(
              'assets/loader.gif',
              width: 80,
            ),
          ),
        ),
      ),
    );
  }

  /// Dismisses the loading overlay only (does not pop the screen underneath).
  static void hide(BuildContext context) {
    if (!context.mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
