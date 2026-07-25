import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/root_navigator.dart';
import 'core/storage/secure_storage_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'services/api/api_client.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/cart_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService();
  final apiClient = ApiClient(storage: storage);
  apiClient.onUnauthorized = () {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  };

  final authRepository = AuthRepository(storage: storage);
  final productRepository = ProductRepository(apiClient: apiClient);
  final orderRepository = OrderRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: apiClient),
        Provider.value(value: authRepository),
        Provider.value(value: productRepository),
        Provider.value(value: orderRepository),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(productRepository: productRepository),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: const BulkMartApp(),
    ),
  );
}

class BulkMartApp extends StatelessWidget {
  const BulkMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'BulkMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
