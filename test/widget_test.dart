import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bulkmart/core/storage/secure_storage_service.dart';
import 'package:bulkmart/repositories/auth_repository.dart';
import 'package:bulkmart/repositories/order_repository.dart';
import 'package:bulkmart/repositories/product_repository.dart';
import 'package:bulkmart/theme/app_theme.dart';
import 'package:bulkmart/viewmodels/auth_view_model.dart';
import 'package:bulkmart/viewmodels/cart_view_model.dart';
import 'package:bulkmart/viewmodels/home_view_model.dart';
import 'package:bulkmart/views/screens/auth/login_screen.dart';

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
