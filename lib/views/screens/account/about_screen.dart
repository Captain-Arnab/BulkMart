import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/ui/app_motion.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('About', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/branding/veggiicart_logo_transparent.png',
                  width: 220,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'VeggiiCart',
                ),
                const SizedBox(height: 16),
                Text(
                  'B2B bulk grocery ordering · Cash on Delivery',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          const _InfoCard(
            title: 'Terms of Service',
            body:
                'By using VeggiiCart you agree to place wholesale orders for business use, honour MOQs, and pay Cash on Delivery when your order arrives.',
          ).animate().fadeIn(delay: 60.ms, duration: 220.ms),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Privacy',
            body:
                'We store your business profile, delivery addresses, and order history to fulfil COD deliveries. We never collect card or UPI details.',
          ).animate().fadeIn(delay: 120.ms, duration: 220.ms),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Payment',
            body: 'Cash on Delivery is the only payment method on VeggiiCart — by design.',
          ).animate().fadeIn(delay: 180.ms, duration: 220.ms),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.body(fontSize: 13, color: AppColors.muted, height: 1.45),
          ),
        ],
      ),
    );
  }
}
