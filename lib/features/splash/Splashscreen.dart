import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/notifications/post_login_device_sync.dart';
import 'package:urban_roots/features/dashboard/dashboard.dart';
import 'package:urban_roots/features/auth/presentation/welcome_screen.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';
import 'package:urban_roots/core/auth/auth_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () => _fadeController.forward());

    Timer(const Duration(seconds: 3), _routeFromSession);
  }

  Future<void> _routeFromSession() async {
    if (!mounted) return;

    // Resume whichever session was last active so the user/vendor does not have
    // to log in again on every cold boot. Routing is based on the saved role:
    //   vendor token + role=vendor → Vendor panel
    //   user token   + role=user   → user Dashboard
    //   otherwise                  → Welcome screen
    final role = await AuthSession.instance.getRole();
    final loggedIn = await AuthSession.instance.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
      return;
    }

    if (role == AuthRole.vendor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VendorShell()),
      );
      return;
    }

    await syncDeviceTokenAfterAuth(role: AuthRole.user);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('assets/logo.png', width: 180, height: 180, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(children: [
                  Text('Urbun Roots', style: GoogleFonts.rubik(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('Fresh & Natural Groceries', style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70, letterSpacing: 0.5)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
