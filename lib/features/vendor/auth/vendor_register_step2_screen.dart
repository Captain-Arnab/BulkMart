import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/navigation/vendor_navigation.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_auth_controller.dart';

class VendorRegisterStep2Screen extends StatefulWidget {
  const VendorRegisterStep2Screen({super.key, required this.email});

  final String email;

  @override
  State<VendorRegisterStep2Screen> createState() =>
      _VendorRegisterStep2ScreenState();
}

class _VendorRegisterStep2ScreenState extends State<VendorRegisterStep2Screen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final VendorAuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.isRegistered<VendorAuthController>()
        ? Get.find<VendorAuthController>()
        : Get.put(VendorAuthController());
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.verifyOtp(
      email: widget.email,
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;
    if (ok) navigateToVendorLogin(context);
  }

  Future<void> _resend() async {
    await _auth.sendOtp(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Verify OTP', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('OTP sent to ${widget.email}', style: GoogleFonts.rubik()),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return 'Enter 6-digit OTP';
                    }
                    return null;
                  },
                ),
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_auth.errorMessage.value, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _auth.isLoading.value ? null : _verify,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _auth.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
                TextButton(onPressed: _resend, child: const Text('Resend OTP')),
              ],
            ),
          ),
        );
      }),
    );
  }
}
