import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../cancellation_policy_screen.dart';
import '../terms_conditions_screen.dart';

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
                  'VeggiiCart · Cash on Delivery',
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _LegalNavRow(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () => AppPageRoute.push(
                    context,
                    const TermsConditionsScreen(),
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                _LegalNavRow(
                  icon: Icons.cancel_outlined,
                  label: 'Cancellation Policy',
                  onTap: () => AppPageRoute.push(
                    context,
                    const CancellationPolicyScreen(),
                  ),
                ),
              ],
            ),
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
            body:
                'Cash on Delivery is the only payment method on VeggiiCart — by design.',
          ).animate().fadeIn(delay: 180.ms, duration: 220.ms),
        ],
      ),
    );
  }
}

class _LegalNavRow extends StatelessWidget {
  const _LegalNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, size: 18, color: AppColors.forest),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
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
          Text(
            title,
            style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.body(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
