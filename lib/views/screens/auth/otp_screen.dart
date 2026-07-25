import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../repositories/auth_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/primary_button.dart';
import '../home/main_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final auth = context.read<AuthViewModel>();
    final ok = await auth.verifyOtp(_otpController.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final masked = auth.mobile.length >= 4
        ? '******${auth.mobile.substring(auth.mobile.length - 4)}'
        : auth.mobile;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Verify OTP', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 4-digit code sent to +91 $masked',
              style: AppTextStyles.body(color: AppColors.slate, height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              'Demo OTP: ${AuthRepository.demoOtp}',
              style: AppTextStyles.mono(fontSize: 11, color: AppColors.mustard),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _otpController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(fontSize: 28, fontWeight: FontWeight.w700),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
              ),
              maxLength: 4,
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) {
                if (_otpController.text.length == 4) _verify();
              },
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: AppTextStyles.body(fontSize: 13, color: AppColors.rust),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Verify & Continue',
              isLoading: auth.isLoading,
              onPressed: _otpController.text.length == 4 ? _verify : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await auth.sendOtp();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP resent (demo: 1234)')),
                        );
                      },
                child: Text(
                  'Resend OTP',
                  style: AppTextStyles.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
