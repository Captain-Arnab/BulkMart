import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/auth_widgets.dart';

/// Demo stub — no real email is sent (matches kDemoMode pattern).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.emailHint = ''});

  final String emailHint;

  @override
  Widget build(BuildContext context) {
    final display = emailHint.isNotEmpty ? emailHint : 'your email';

    return AuthScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                ),
              ),
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: AppColors.green,
                  ),
                ).animate().fadeIn(duration: 220.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 260.ms,
                    ),
              ),
              const SizedBox(height: 28),
              Text(
                'Reset link sent',
                style: AppTextStyles.display(fontSize: 28),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 60.ms, duration: 220.ms),
              const SizedBox(height: 12),
              Text(
                'Reset link sent to your email ($display). Check your inbox — demo mode, no real email was sent.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 220.ms),
              const Spacer(flex: 3),
              AuthPrimaryButton(
                label: 'Back to Login',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
