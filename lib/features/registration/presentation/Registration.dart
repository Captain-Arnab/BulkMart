import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/Loader.dart';
import 'package:urban_roots/Utils/Strings.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/login/presentation/Login.dart';
import 'package:urban_roots/features/registration/data/RegistrationController.dart';

class Registration extends StatefulWidget {
  Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  RegistrationController registrationController = Get.put(RegistrationController());

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.green.shade400, size: 20),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(text, style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF019934),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset("assets/logo.png", width: 120, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text('Create Account', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Join us for fresh groceries', style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('First Name'),
                    TextFormField(controller: registrationController.registerFirstNameController, style: GoogleFonts.poppins(fontSize: 14), decoration: _inputDecoration('Enter first name', Icons.person_outline)),
                    _label('Last Name'),
                    TextFormField(controller: registrationController.registerLastNameController, style: GoogleFonts.poppins(fontSize: 14), decoration: _inputDecoration('Enter last name', Icons.person_outline)),
                    _label('Phone Number'),
                    TextFormField(controller: registrationController.registerPhoneNumberController, style: GoogleFonts.poppins(fontSize: 14), keyboardType: TextInputType.phone, decoration: _inputDecoration('Enter phone number', Icons.phone_outlined)),
                    _label('Email'),
                    TextFormField(controller: registrationController.registerEmailController, style: GoogleFonts.poppins(fontSize: 14), keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Enter email', Icons.email_outlined)),
                    _label('Password'),
                    TextFormField(
                      controller: registrationController.registerPasswordController,
                      obscureText: !registrationController.passwordVisible.value,
                      decoration: _inputDecoration('Create password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(registrationController.passwordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade500, size: 20),
                          onPressed: () => setState(() => registrationController.passwordVisible.value = !registrationController.passwordVisible.value),
                        ),
                      ),
                    ),
                    _label('Confirm Password'),
                    TextFormField(controller: registrationController.registerConfirmPasswordController, obscureText: true, style: GoogleFonts.poppins(fontSize: 14), decoration: _inputDecoration('Confirm password', Icons.lock_outline)),
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
                          final validationError = registrationController.validateForm();
                          if (validationError != null) {
                            await SweetAlert.warning(context, message: validationError);
                            return;
                          }

                          Loader.show(context);
                          late final RegistrationResult result;
                          try {
                            result = await registrationController.registerUser(
                              registrationController.registerFirstNameController.text,
                              registrationController.registerLastNameController.text,
                              registrationController.registerPhoneNumberController.text,
                              registrationController.registerEmailController.text,
                              registrationController.registerPasswordController.text,
                              registrationController.registerConfirmPasswordController.text,
                            );
                          } finally {
                            if (context.mounted) Loader.hide(context);
                          }

                          if (!context.mounted) return;

                          if (result.success) {
                            registrationController.clearData();
                            await SweetAlert.success(
                              context,
                              title: 'Registration Successful!',
                              message:
                                  'Your account has been created. Please login to continue.',
                              confirmText: 'Go to Login',
                            );
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => Login()),
                            );
                            return;
                          }

                          final errorMessage = result.message;
                          if (errorMessage == null) return;

                          if (result.redirectToLogin) {
                            await SweetAlert.info(
                              context,
                              title: 'Account Already Exists',
                              message: errorMessage,
                              confirmText: 'Go to Login',
                            );
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => Login()),
                            );
                            return;
                          }

                          await SweetAlert.error(
                            context,
                            message: errorMessage,
                          );
                        },
                        child: Text("Create Account", style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: Strings.loginText, style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade600)),
                          TextSpan(
                            text: 'Login',
                            style: GoogleFonts.rubik(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF019934)),
                            recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login())),
                          ),
                        ]),
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
