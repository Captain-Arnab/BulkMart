import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/auth_widgets.dart';
import '../home/main_shell.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SafeArea(
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
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 220.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 280.ms,
                    curve: AppMotion.pop,
                  ),
              const SizedBox(height: 16),
              Text(
                "You're all set!",
                style: AppTextStyles.display(fontSize: 28),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 220.ms)
                  .slideY(begin: 0.1, end: 0, delay: 80.ms),
              const SizedBox(height: 10),
              Text(
                'Your account is ready — start shopping on VeggiiCart.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ).animate().fadeIn(delay: 140.ms, duration: 220.ms),
              const Spacer(),
              AuthPrimaryButton(
                label: 'Go to Home',
                onPressed: () {
                  AppPageRoute.pushAndRemoveUntil(context, const MainShell());
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
