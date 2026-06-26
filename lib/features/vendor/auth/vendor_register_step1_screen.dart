import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/auth/vendor_register_step2_screen.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_auth_controller.dart';

class VendorRegisterStep1Screen extends StatefulWidget {
  const VendorRegisterStep1Screen({super.key});

  @override
  State<VendorRegisterStep1Screen> createState() =>
      _VendorRegisterStep1ScreenState();
}

class _VendorRegisterStep1ScreenState extends State<VendorRegisterStep1Screen> {
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final ok = await _auth.sendOtp(email);
    if (!mounted) return;
    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorRegisterStep2Screen(email: email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Vendor Registration',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
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
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter email' : null,
                ),
                if (_auth.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_auth.errorMessage.value,
                      style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _auth.isLoading.value ? null : _sendOtp,
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
                      : const Text('Send OTP'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
