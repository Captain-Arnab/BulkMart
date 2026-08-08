import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../models/kyc_status.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import '../home/main_shell.dart';
import 'registration_screen.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key, this.fromProfile = false});

  /// When opened from Profile Details — offer back navigation instead of
  /// forcing Home / re-registration flows.
  final bool fromProfile;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final status = auth.user?.kycStatus ?? KycStatus.pending;
    final reason = auth.user?.kycRejectionReason;

    late final IconData icon;
    late final Color color;
    late final String title;
    late final String body;

    switch (status) {
      case KycStatus.pending:
        icon = Icons.hourglass_top_rounded;
        color = const Color(0xFFE6A700);
        title = 'Pending Review';
        body =
            'Your application is under review. This usually takes 24–48 hours.';
      case KycStatus.approved:
        icon = Icons.verified_rounded;
        color = AppColors.success;
        title = "You're verified!";
        body = 'Start ordering in bulk with wholesale MOQs and COD delivery.';
      case KycStatus.rejected:
        icon = Icons.cancel_rounded;
        color = AppColors.alert;
        title = 'Application rejected';
        body = reason?.trim().isNotEmpty == true
            ? reason!
            : 'Please re-upload the required documents and resubmit.';
    }

    return Scaffold(
      backgroundColor: AppColors.section,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              if (fromProfile || Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  ),
                ),
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: color),
              )
                  .animate()
                  .fadeIn(duration: 220.ms)
                  .scale(begin: const Offset(0.86, 0.86), curve: AppMotion.pop),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.display(fontSize: 26),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              if (status == KycStatus.pending && AppConfig.kDemoMode) ...[
                AuthPrimaryButton(
                  label: fromProfile ? 'Mark Approved (Demo)' : 'Continue in Demo Mode',
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    final ok = await auth.approveKycDemo();
                    if (!context.mounted || !ok) return;
                    if (fromProfile) {
                      Navigator.of(context).pop();
                    } else {
                      await AppPageRoute.pushAndRemoveUntil(
                        context,
                        const MainShell(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Demo only — hidden when kDemoMode is false',
                  style: AppTextStyles.body(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
              ],
              if (status == KycStatus.approved)
                AuthPrimaryButton(
                  label: fromProfile ? 'Done' : 'Go to Home',
                  onPressed: () {
                    if (fromProfile) {
                      Navigator.of(context).pop();
                    } else {
                      AppPageRoute.pushAndRemoveUntil(context, const MainShell());
                    }
                  },
                ),
              if (status == KycStatus.rejected)
                AuthPrimaryButton(
                  label: fromProfile ? 'Back to Documents' : 'Re-upload Documents',
                  onPressed: () {
                    if (fromProfile) {
                      Navigator.of(context).pop();
                    } else {
                      AppPageRoute.pushReplacement(
                        context,
                        const RegistrationScreen(initialStep: 3),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
