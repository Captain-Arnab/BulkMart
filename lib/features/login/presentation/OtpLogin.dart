import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/demo_auth.dart';
import 'package:urban_roots/features/login/data/LoginController.dart';
import 'package:urban_roots/features/login/presentation/Login.dart';
import 'package:urban_roots/features/login/presentation/OtpVerificationPage.dart';
import 'package:urban_roots/features/login/presentation/widgets/role_selector.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final LoginController _loginController =
      Get.isRegistered<LoginController>() ? Get.find<LoginController>() : Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF019934),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset('assets/logo.png', width: 160, height: 160, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              'Phone Login',
              style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in with mobile number & password',
              style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            // Text(
            //   'Customer: ${DemoAuth.demoPhone} · Vendor: ${DemoAuth.demoVendorPhone}',
            //   style: GoogleFonts.rubik(fontSize: 11, color: Colors.white60),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: _fieldDecoration(
                        hint: 'Enter mobile number',
                        prefixIcon: Icons.phone_outlined,
                        prefixText: '+91 ',
                      ),
                    ),
                    const SizedBox(height: 18),
                    RoleSelector(controller: _loginController),
                    const SizedBox(height: 18),
                    Text(
                      'Password',
                      style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => TextFormField(
                        controller: _loginController.passwordController,
                        obscureText: !_loginController.passwordVisible.value,
                        decoration: _fieldDecoration(
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _loginController.passwordVisible.value ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            onPressed: () => _loginController.passwordVisible.value = !_loginController.passwordVisible.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF019934),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: _continueToOtp,
                        child: Text(
                          'Continue',
                          style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => Login()),
                        ),
                        child: Text(
                          'Login with email',
                          style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF019934)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _continueToOtp() {
    final phone = _phoneController.text.trim();
    final password = _loginController.passwordController.text;

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }
    if (!DemoAuth.isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid mobile number')),
      );
      return;
    }
    if (!DemoAuth.isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          loginMethod: LoginMethod.phone,
          identifier: phone,
          selectedRole: _loginController.selectedRole.value,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      counterText: '',
      prefixIcon: Icon(prefixIcon, color: Colors.green.shade400, size: 20),
      prefixText: prefixText,
      prefixStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
