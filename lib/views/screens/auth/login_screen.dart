import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import '../home/main_shell.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';
import 'registration_screen.dart';

enum _LoginTab { mobile, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginTab _tab = _LoginTab.mobile;

  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _mobileError;
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _mobileValid => _mobileController.text.trim().length == 10;

  bool get _emailValid {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    return _emailRegex.hasMatch(email) && pass.length >= 6;
  }

  Future<void> _onSendOtp() async {
    if (!_mobileValid) {
      setState(() => _mobileError = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() => _mobileError = null);
    final auth = context.read<AuthViewModel>();
    auth.startLoginFlow();
    auth.setMobile(_mobileController.text.trim());
    final ok = await auth.sendOtp();
    if (!mounted) return;
    if (ok) {
      await AppPageRoute.push(context, const OtpScreen());
    } else if (auth.error != null) {
      setState(() => _mobileError = auth.error);
    }
  }

  Future<void> _onEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? passErr;
    if (!_emailRegex.hasMatch(email)) {
      emailErr = 'Enter a valid email address';
    }
    if (password.length < 6) {
      passErr = 'Password must be at least 6 characters';
    }
    if (emailErr != null || passErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passErr;
      });
      return;
    }
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final auth = context.read<AuthViewModel>();
    auth.startLoginFlow();
    final ok = await auth.loginWithEmail(email: email, password: password);
    if (!mounted) return;
    if (ok) {
      await AppPageRoute.pushAndRemoveUntil(context, const MainShell());
    } else if (auth.error != null) {
      setState(() => _passwordError = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return AuthScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppShadows.card,
                  ),
                  child: Image.asset(
                    'assets/branding/veggiicart_icon_mark.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.eco_rounded,
                      size: 40,
                      color: AppColors.green.withValues(alpha: 0.9),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 260.ms,
                      curve: AppMotion.pop,
                    ),
              ),
              const SizedBox(height: 28),
              Text(
                'Bulk ordering,\nsorted.',
                style: AppTextStyles.display(fontSize: 32, height: 1.15),
              )
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 220.ms)
                  .slideY(begin: 0.12, end: 0, delay: 60.ms, duration: 220.ms),
              const SizedBox(height: 10),
              Text(
                _tab == _LoginTab.mobile
                    ? 'Login with your business mobile number'
                    : 'Login with email & password',
                style: AppTextStyles.body(fontSize: 14, color: AppColors.muted, height: 1.4),
              ).animate().fadeIn(delay: 120.ms, duration: 220.ms),
              const SizedBox(height: 24),
              _LoginMethodTabs(
                tab: _tab,
                onChanged: (t) => setState(() {
                  _tab = t;
                  _mobileError = null;
                  _emailError = null;
                  _passwordError = null;
                }),
              ).animate().fadeIn(delay: 140.ms, duration: 200.ms),
              const SizedBox(height: 28),
              if (_tab == _LoginTab.mobile) ...[
                const AuthFieldLabel('Mobile number')
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 200.ms)
                    .slideY(begin: 0.15, end: 0, delay: 160.ms, duration: 220.ms),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _mobileController,
                  hint: '9xxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefix: const CountryCodeChip(),
                  errorText: _mobileError,
                  onChanged: (_) {
                    if (_mobileError != null) setState(() => _mobileError = null);
                    setState(() {});
                  },
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 200.ms)
                    .slideY(begin: 0.15, end: 0, delay: 200.ms, duration: 220.ms),
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: 'Send OTP',
                  isLoading: auth.isLoading,
                  enabled: _mobileValid,
                  onPressed: _onSendOtp,
                )
                    .animate()
                    .fadeIn(delay: 260.ms, duration: 200.ms)
                    .slideY(begin: 0.15, end: 0, delay: 260.ms, duration: 220.ms),
              ] else ...[
                const AuthFieldLabel('Email'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _emailController,
                  hint: 'you@business.com',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('Password'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _passwordController,
                  hint: 'Min. 6 characters',
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  errorText: _passwordError,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 22,
                    ),
                  ),
                  onChanged: (_) {
                    if (_passwordError != null) setState(() => _passwordError = null);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      AppPageRoute.push(
                        context,
                        ForgotPasswordScreen(
                          emailHint: _emailController.text.trim(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Login',
                  isLoading: auth.isLoading,
                  enabled: _emailValid,
                  onPressed: _onEmailLogin,
                ),
              ],
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () {
                    auth.startRegisterFlow();
                    AppPageRoute.push(context, const RegistrationScreen());
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'New here? ',
                      style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                      children: [
                        TextSpan(
                          text: 'Register your business',
                          style: AppTextStyles.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 200.ms),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  'B2B only — verified wholesale, restaurant and bulk-purchase accounts.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.muted, height: 1.4),
                ),
              ).animate().fadeIn(delay: 340.ms, duration: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginMethodTabs extends StatelessWidget {
  const _LoginMethodTabs({required this.tab, required this.onChanged});

  final _LoginTab tab;
  final ValueChanged<_LoginTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'Mobile Number',
              selected: tab == _LoginTab.mobile,
              onTap: () => onChanged(_LoginTab.mobile),
            ),
          ),
          Expanded(
            child: _TabChip(
              label: 'Email & Password',
              selected: tab == _LoginTab.email,
              onTap: () => onChanged(_LoginTab.email),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: selected ? AppShadows.soft(color: AppColors.green, opacity: 0.22) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
