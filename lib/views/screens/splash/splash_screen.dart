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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loader;

  @override
  void initState() {
    super.initState();
    _loader = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final auth = context.read<AuthViewModel>();
    final loggedIn = await auth.bootstrapSession();
    if (!mounted) return;
    await AppPageRoute.pushReplacement(
      context,
      loggedIn ? const MainShell() : const LoginScreen(),
      slide: false,
    );
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
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
              colors: [Color(0xFF7B2FF7), Color(0xFF9B4DFF)],
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
                          color: AppColors.violet,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 180.ms)
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1.05, 1.05),
                          duration: 320.ms,
                          curve: AppMotion.pop,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.05, 1.05),
                          end: const Offset(1, 1),
                          duration: 160.ms,
                          curve: AppMotion.ease,
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
                        .fadeIn(delay: 150.ms, duration: 220.ms, curve: AppMotion.ease)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 150.ms,
                          duration: 220.ms,
                          curve: AppMotion.ease,
                        ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 56 + MediaQuery.paddingOf(context).bottom,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _loader,
                    builder: (_, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final phase = (_loader.value + i * 0.2) % 1.0;
                          final scale = 0.7 + (0.3 * (1 - (phase - 0.5).abs() * 2).clamp(0, 1));
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            transform: Matrix4.diagonal3Values(scale, scale, 1),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.55 + 0.45 * scale),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      );
                    },
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
