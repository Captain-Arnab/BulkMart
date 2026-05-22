import 'package:flutter/material.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/Dashboard.dart';
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
