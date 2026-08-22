import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../models/kyc_status.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import '../home/main_shell.dart';
import 'registration_screen.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key, this.fromProfile = false});

  /// When opened from Profile Details — offer back navigation instead of
  /// forcing Home / re-registration flows.
  final bool fromProfile;

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().refreshVerificationStatus();
    });
    _poll = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      final auth = context.read<AuthViewModel>();
      if (auth.user?.kycStatus == KycStatus.pending) {
        auth.refreshVerificationStatus();
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

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
              if (widget.fromProfile || Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.ink),
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
                  .scale(
                      begin: const Offset(0.86, 0.86), curve: AppMotion.pop),
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
              if (status == KycStatus.pending) ...[
                AuthPrimaryButton(
                  label: 'Check status',
                  isLoading: auth.isLoading,
                  onPressed: () => auth.refreshVerificationStatus(),
                ),
                const SizedBox(height: 16),
              ],
              if (status == KycStatus.approved)
                AuthPrimaryButton(
                  label: widget.fromProfile ? 'Done' : 'Go to Home',
                  onPressed: () {
                    if (widget.fromProfile) {
                      Navigator.of(context).pop();
                    } else {
                      AppPageRoute.pushAndRemoveUntil(
                          context, const MainShell());
                    }
                  },
                ),
              if (status == KycStatus.rejected)
                AuthPrimaryButton(
                  label: widget.fromProfile
                      ? 'Back to Documents'
                      : 'Re-upload Documents',
                  onPressed: () {
                    if (widget.fromProfile) {
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
