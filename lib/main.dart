import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_page_route.dart';
import 'core/navigation/root_navigator.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/ui/shell_controller.dart';
import 'repositories/address_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/offer_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/support_repository.dart';
import 'repositories/wishlist_repository.dart';
import 'services/api/api_client.dart';
import 'theme/app_theme.dart';
import 'viewmodels/address_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/cart_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/notification_view_model.dart';
import 'viewmodels/offer_view_model.dart';
import 'viewmodels/wishlist_view_model.dart';
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
      AppPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  };

  final authRepository = AuthRepository(storage: storage);
  final productRepository = ProductRepository(apiClient: apiClient);
  final orderRepository = OrderRepository(apiClient: apiClient);
  final addressRepository = AddressRepository(apiClient: apiClient);
  final supportRepository = SupportRepository(apiClient: apiClient);
  final wishlistRepository = WishlistRepository(apiClient: apiClient);
  final notificationRepository = NotificationRepository(apiClient: apiClient);
  final offerRepository = OfferRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: apiClient),
        Provider.value(value: authRepository),
        Provider.value(value: productRepository),
        Provider.value(value: orderRepository),
        Provider.value(value: addressRepository),
        Provider.value(value: supportRepository),
        Provider.value(value: wishlistRepository),
        Provider.value(value: notificationRepository),
        Provider.value(value: offerRepository),
        ChangeNotifierProvider(create: (_) => ShellController()),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(productRepository: productRepository),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(
          create: (_) => AddressViewModel(addressRepository: addressRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistViewModel(
            wishlistRepository: wishlistRepository,
            productRepository: productRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationViewModel(repository: notificationRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => OfferViewModel(repository: offerRepository)..load(),
        ),
      ],
      child: const VeggiiCartApp(),
    ),
  );

  // Preload fonts after first frame so startup isn't blocked on network I/O.
  unawaited(_preloadFonts());
}

Future<void> _preloadFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.plusJakartaSans(),
      GoogleFonts.inter(),
    ]).timeout(const Duration(seconds: 4));
    GoogleFonts.config.allowRuntimeFetching = false;
  } catch (_) {
    // Keep runtime fetching as fallback if preload failed / timed out.
  }
}

class VeggiiCartApp extends StatelessWidget {
  const VeggiiCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'VeggiiCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
