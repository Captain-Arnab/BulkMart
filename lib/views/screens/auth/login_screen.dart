import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/moq_badge.dart';
import '../../widgets/primary_button.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _businessController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _mobileController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthViewModel>();
    auth.setMobile(_mobileController.text.trim());
    auth.setBusinessName(_businessController.text.trim());
    final ok = await auth.sendOtp();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'B2',
                      style: AppTextStyles.display(fontSize: 20, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome back,\nbulk buyer',
                    style: AppTextStyles.display(fontSize: 26, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with your registered business mobile number to see wholesale pricing.',
                    style: AppTextStyles.body(fontSize: 13, color: AppColors.slate, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Text('MOBILE NUMBER', style: AppTextStyles.label()),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: AppTextStyles.body(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixText: '+91  ',
                      prefixStyle: AppTextStyles.body(fontWeight: FontWeight.w600),
                      hintText: '9xxxxxxxxx',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length != 10) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('BUSINESS NAME', style: AppTextStyles.label()),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _businessController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.body(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Sharma Restaurant Supplies',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Business name is required';
                      }
                      return null;
                    },
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.error!,
                      style: AppTextStyles.body(fontSize: 13, color: AppColors.rust),
                    ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Send OTP',
                    isLoading: auth.isLoading,
                    onPressed: _onSendOtp,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration will open once the API is ready.'),
                          ),
                        );
                      },
                      child: Text(
                        'New here? Register your business',
                        style: AppTextStyles.body(fontSize: 12, color: AppColors.slate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paper2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MoqBadge(
                          title: 'B2B',
                          label: 'ONLY',
                          size: 40,
                          fontSize: 7.5,
                          color: AppColors.forest,
                          rotation: -0.12,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Access is restricted to verified wholesale, restaurant and bulk-purchase accounts.',
                            style: AppTextStyles.body(
                              fontSize: 11,
                              color: AppColors.slate,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
