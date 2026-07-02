import 'package:flutter/material.dart';
import 'package:urban_roots/Utils/Strings.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/navigation/root_navigator.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/auth/presentation/welcome_screen.dart';
import 'package:urban_roots/features/dashboard/dashboard.dart';
import 'package:urban_roots/features/login/presentation/Login.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';

void navigateAfterLogin(BuildContext context, AuthRole role) {
  final destination = role == AuthRole.vendor
      ? const VendorShell()
      : const Dashboard();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (_) => false,
  );
}

void navigateToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => Login()),
    (_) => false,
  );
}

/// Public entry — Sign In / Sign Up (used after vendor logout or session expiry).
void navigateToWelcomeScreen([BuildContext? context]) {
  final ctx = context ?? rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
  Navigator.of(ctx).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (_) => false,
  );
}

Future<void> showLoginSuccessAndNavigate(
  BuildContext context,
  AuthRole role,
) {
  return SweetAlert.success(
    context,
    title: 'Welcome',
    message: Strings.loginSuccess,
    onConfirm: () {
      if (context.mounted) navigateAfterLogin(context, role);
    },
  );
}

Future<void> showLogoutSuccessAndNavigate([BuildContext? context]) {
  final ctx = context ?? rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) {
    return Future.value();
  }
  return SweetAlert.success(
    ctx,
    title: 'Logged out',
    message: Strings.logoutSuccess,
    onConfirm: () {
      final loginCtx = rootNavigatorKey.currentContext;
      if (loginCtx != null && loginCtx.mounted) {
        navigateToLogin(loginCtx);
      }
    },
  );
}
