import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:veggiicart/core/storage/secure_storage_service.dart';
import 'package:veggiicart/repositories/auth_repository.dart';
import 'package:veggiicart/repositories/order_repository.dart';
import 'package:veggiicart/repositories/product_repository.dart';
import 'package:veggiicart/theme/app_theme.dart';
import 'package:veggiicart/viewmodels/auth_view_model.dart';
import 'package:veggiicart/viewmodels/cart_view_model.dart';
import 'package:veggiicart/viewmodels/home_view_model.dart';
import 'package:veggiicart/views/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen renders bulk ordering headline', (tester) async {
    final storage = SecureStorageService();
    final authRepository = AuthRepository(storage: storage);
    final productRepository = ProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: authRepository),
          Provider.value(value: productRepository),
          Provider.value(value: OrderRepository()),
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(authRepository: authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => HomeViewModel(productRepository: productRepository),
          ),
          ChangeNotifierProvider(create: (_) => CartViewModel()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('Bulk ordering'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.textContaining('Register your business'), findsOneWidget);
  });
}
