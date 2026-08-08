import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../models/kyc_status.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../auth/login_screen.dart';
import '../auth/verification_status_screen.dart';
import '../home/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthViewModel>();
    final results = await Future.wait<Object?>([
      auth.bootstrapSession(),
      Future<void>.delayed(const Duration(milliseconds: 500)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first as bool;
    final Widget next;
    if (!loggedIn) {
      next = const LoginScreen();
    } else if (auth.user?.kycStatus != null &&
        auth.user!.kycStatus != KycStatus.approved) {
      next = const VerificationStatusScreen();
    } else {
      next = const MainShell();
    }
    await AppPageRoute.pushReplacement(context, next, slide: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.forest, AppColors.green],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Symbol-only mark in a circle — never the wide wordmark logo.
                    Container(
                      width: 128,
                      height: 128,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/branding/veggiicart_icon_mark.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        semanticLabel: 'VeggiiCart',
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .scale(
                          begin: const Offset(0.88, 0.88),
                          end: const Offset(1, 1),
                          duration: 300.ms,
                          curve: AppMotion.pop,
                        ),
                    const SizedBox(height: 22),
                    Text(
                      'VeggiiCart',
                      style: AppTextStyles.display(
                        fontSize: 28,
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 260.ms)
                        .slideY(
                          begin: 0.18,
                          end: 0,
                          delay: 80.ms,
                          duration: 280.ms,
                          curve: AppMotion.ease,
                        ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 56 + MediaQuery.paddingOf(context).bottom,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.white,
                    ),
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
