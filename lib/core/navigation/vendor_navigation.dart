import 'package:flutter/material.dart';
import 'package:urban_roots/core/navigation/root_navigator.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';

void navigateToVendorDashboard([BuildContext? context]) {
  final ctx = context ?? rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
  Navigator.of(ctx).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const VendorShell()),
    (_) => false,
  );
}
