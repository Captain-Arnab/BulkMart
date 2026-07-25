import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/profile_avatar.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'addresses_screen.dart';
import 'profile_details_screen.dart';
import 'support_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;
    final shell = context.read<ShellController>();

    return Scaffold(
      backgroundColor: AppColors.section,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Text('Account', style: AppTextStyles.display(fontSize: 26))
                .animate()
                .fadeIn(duration: 200.ms)
                .slideY(begin: 0.08, end: 0),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EBFF),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(user: user, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.businessName ?? 'Your business',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null ? '+91 ${user.mobile}' : '—',
                          style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    onTap: () => AppPageRoute.push(context, const ProfileDetailsScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: AppColors.violet),
                      ),
                      child: Text(
                        'Edit',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 60.ms, duration: 220.ms)
                .slideY(begin: 0.1, end: 0, delay: 60.ms),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  _AccountRow(
                    icon: Icons.receipt_long_rounded,
                    iconBg: AppColors.violet,
                    label: 'My Orders',
                    onTap: shell.goToOrders,
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  _AccountRow(
                    icon: Icons.location_on_rounded,
                    iconBg: AppColors.accent,
                    iconColor: AppColors.ink,
                    label: 'Saved Addresses',
                    onTap: () => AppPageRoute.push(context, const AddressesScreen()),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  _AccountRow(
                    icon: Icons.support_agent_rounded,
                    iconBg: AppColors.success,
                    label: 'Help & Support',
                    onTap: () => AppPageRoute.push(context, const SupportScreen()),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  _AccountRow(
                    icon: Icons.info_outline_rounded,
                    iconBg: AppColors.muted,
                    label: 'About',
                    onTap: () => AppPageRoute.push(context, const AboutScreen()),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 120.ms, duration: 220.ms)
                .slideY(begin: 0.1, end: 0, delay: 120.ms),
            const SizedBox(height: 28),
            PressableScale(
              onTap: () async {
                await auth.logout();
                if (!context.mounted) return;
                await AppPageRoute.pushAndRemoveUntil(context, const LoginScreen());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Log Out',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.alert,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.white,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
