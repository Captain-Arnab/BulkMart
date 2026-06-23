import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/core/navigation/vendor_navigation.dart';
import 'package:urban_roots/core/navigation/root_navigator.dart';
import 'package:urban_roots/core/notifications/push_notification_service.dart';
import 'package:urban_roots/data/network/api_client.dart';
import 'package:urban_roots/core/theme/app_theme.dart';
import 'package:urban_roots/features/splash/Splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await PushNotificationService.instance.initialize();
  } catch (e, stack) {
    debugPrint('[Startup] Firebase init failed: $e\n$stack');
  }
  ApiClient.user.onUnauthorized = () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) navigateToLogin(context);
  };
  ApiClient.vendor.onUnauthorized = () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) navigateToVendorLogin(context);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Urban Roots',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: SplashScreen(),
    );
  }
}
