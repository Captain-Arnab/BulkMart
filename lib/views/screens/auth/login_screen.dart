import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import 'otp_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  String? _mobileError;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool get _valid => _mobileController.text.trim().length == 10;

  Future<void> _onSendOtp() async {
    if (!_valid) {
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
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 40,
                    color: AppColors.violet.withValues(alpha: 0.9),
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
                'Login with your business mobile number',
                style: AppTextStyles.body(fontSize: 14, color: AppColors.muted, height: 1.4),
              ).animate().fadeIn(delay: 120.ms, duration: 220.ms),
              const SizedBox(height: 32),
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
                enabled: _valid,
                onPressed: _onSendOtp,
              )
                  .animate()
                  .fadeIn(delay: 260.ms, duration: 200.ms)
                  .slideY(begin: 0.15, end: 0, delay: 260.ms, duration: 220.ms),
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
                            color: AppColors.violet,
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
