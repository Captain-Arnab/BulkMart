import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/navigation/root_navigator.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/order.dart';
import '../../../models/payment_method.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../orders/order_detail_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final shell = context.read<ShellController>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 160,
                child: Lottie.asset(
                  'assets/lottie/success_check.json',
                  repeat: false,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 280.ms, curve: AppMotion.ease)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 16),
              Text(
                'Order placed',
                style: AppTextStyles.display(fontSize: 26),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 240.ms)
                  .slideY(begin: 0.12, end: 0, delay: 80.ms, duration: 240.ms, curve: AppMotion.ease),
              const SizedBox(height: 8),
              Text(
                'Your COD order is confirmed. Our delivery team will set a date shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.slate, height: 1.5),
              )
                  .animate()
                  .fadeIn(delay: 140.ms, duration: 240.ms),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.line),
                  boxShadow: AppShadows.soft(opacity: 0.06),
                ),
                child: Column(
                  children: [
                    Text('ORDER ID', style: AppTextStyles.label(fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      order.id,
                      style: AppTextStyles.mono(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _priceFormat.format(order.total),
                      style: AppTextStyles.display(fontSize: 22, color: AppColors.forestDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} items · ${order.paymentMethod.paymentMethodLabel}',
                      style: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 260.ms)
                  .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 260.ms, curve: AppMotion.ease),
              const Spacer(),
              PrimaryButton(
                label: 'Track Order',
                onPressed: () {
                  final id = order.id;
                  Navigator.of(context).pop();
                  shell.goToOrders();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    rootNavigatorKey.currentState?.push(
                      AppPageRoute(builder: (_) => OrderDetailScreen(orderId: id)),
                    );
                  });
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  shell.goToHome();
                },
                child: Text(
                  'Back to catalog',
                  style: AppTextStyles.body(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
