import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../auth/login_screen.dart';
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
    // Wait until after the first frame so bootstrap notifyListeners can't
    // mark InheritedProviders dirty while the tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthViewModel>();
    // Session check runs immediately; short min delay only for brand presence.
    final results = await Future.wait<Object?>([
      auth.bootstrapSession(),
      Future<void>.delayed(const Duration(milliseconds: 500)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first as bool;
    await AppPageRoute.pushReplacement(
      context,
      loggedIn ? const MainShell() : const LoginScreen(),
      slide: false,
    );
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
              colors: [AppColors.green, AppColors.greenLight],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Text(
                        'BM',
                        style: AppTextStyles.display(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 180.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 280.ms,
                          curve: AppMotion.pop,
                        ),
                    const SizedBox(height: 20),
                    Text(
                      'BulkMart',
                      style: AppTextStyles.display(
                        fontSize: 32,
                        color: AppColors.white,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 200.ms, curve: AppMotion.ease)
                        .slideY(
                          begin: 0.12,
                          end: 0,
                          delay: 100.ms,
                          duration: 200.ms,
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
