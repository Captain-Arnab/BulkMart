import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/Strings.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/core/notifications/post_login_device_sync.dart';
import 'package:urban_roots/data/models/login_response.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/repositories/auth_repository.dart';
import 'package:urban_roots/features/login/data/LoginController.dart';
import 'package:urban_roots/features/login/presentation/OtpLogin.dart';
import 'package:urban_roots/features/login/presentation/widgets/role_selector.dart';
import 'package:urban_roots/features/registration/presentation/Registration.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var cellHeight = 50.0;
    var cellWidth = screenSize.width - 70;

    return Scaffold(
      backgroundColor: const Color(0xFF019934),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset(
              "assets/logo.png",
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome Back!',
              style: GoogleFonts.rubik(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to continue shopping',
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
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
                    Text('Email', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: loginController.emailController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade400, size: 20),
                        hintText: 'Enter your email',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 18),
                    RoleSelector(controller: loginController),
                    const SizedBox(height: 18),
                    Text('Password', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Obx(() => TextFormField(
                      controller: loginController.passwordController,
                      obscureText: !loginController.passwordVisible.value,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade400, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.passwordVisible.value ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () => loginController.passwordVisible.value = !loginController.passwordVisible.value,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    )),
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
                        onPressed: () async {
                          final email = loginController.emailController.text.trim();
                          final password = loginController.passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            await SweetAlert.warning(context, message: 'Please fill email and password');
                            return;
                          }

                          loginController.isLoading(true);
                          final authRepo = LiveAuthRepository();
                          final result = await authRepo.login(
                            identifier: email,
                            password: password,
                            selectedRole: loginController.selectedRole.value,
                          );
                          loginController.isLoading(false);

                          if (result is ApiFailure<LoginResponse>) {
                            if (!context.mounted) return;
                            await SweetAlert.error(context, message: result.message);
                            return;
                          }

                          final response =
                              (result as ApiSuccess<LoginResponse>).data;
                          await AuthSession.instance.save(
                            token: response.token,
                            role: response.role,
                            vendorId: response.vendorId,
                            userId: response.userId,
                            displayName: response.name,
                          );
                          await syncDeviceTokenAfterAuth(role: response.role);
                          if (!context.mounted) return;
                          await showLoginSuccessAndNavigate(context, response.role);
                        },
                        child: Text('Continue', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OTPVerificationScreen())),
                        child: Text(
                          'Login with phone & OTP (no password)',
                          style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF019934)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: Strings.completeRegistration, style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade600)),
                            TextSpan(
                              text: 'Create here',
                              style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF019934)),
                              recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Registration())),
                            ),
                          ],
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
}
