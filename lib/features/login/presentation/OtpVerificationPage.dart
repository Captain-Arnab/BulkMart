import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/data/demo_auth.dart';
import 'package:urban_roots/data/repositories/auth_repository.dart';

enum LoginMethod { email, phone }

class OtpVerificationPage extends StatefulWidget {
  final LoginMethod loginMethod;
  final String identifier;
  final AuthRole? selectedRole;

  const OtpVerificationPage({
    super.key,
    required this.loginMethod,
    required this.identifier,
    this.selectedRole,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        return true;
      }
      return false;
    });
  }

  AuthRole? _resolveRole() {
    if (widget.loginMethod == LoginMethod.email &&
        DemoAuth.isVendorEmail(widget.identifier)) {
      return AuthRole.vendor;
    }
    if (widget.loginMethod == LoginMethod.phone &&
        DemoAuth.isVendorPhone(widget.identifier)) {
      return AuthRole.vendor;
    }
    return widget.selectedRole;
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    if (!DemoAuth.isValidOtp(_otpController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final authRepo = MockAuthRepository();
      final inferredRole = _resolveRole();

      final response = await authRepo.login(
        identifier: widget.identifier,
        selectedRole: inferredRole,
      );

      await AuthSession.instance.save(
        token: response.token,
        role: response.role,
        vendorId: response.vendorId,
        displayName: response.name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 600),
          content: Text('Login successful!'),
          backgroundColor: Color(0xFF019934),
        ),
      );
      navigateAfterLogin(context, response.role);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.loginMethod == LoginMethod.phone;
    final masked = DemoAuth.maskIdentifier(widget.identifier, isPhone: isPhone);

    return Scaffold(
      backgroundColor: const Color(0xFF019934),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              'Verify OTP',
              style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Code sent to $masked',
              style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
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
                    Text(
                      'Enter OTP',
                      style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otpController,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.poppins(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '• • • • • •',
                        hintStyle: GoogleFonts.poppins(fontSize: 22, color: Colors.grey.shade300, letterSpacing: 6),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: _resendSeconds > 0
                          ? Text(
                              'Resend OTP in ${_resendSeconds}s',
                              style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade500),
                            )
                          : TextButton(
                              onPressed: () {
                                setState(() => _resendSeconds = 30);
                                _startResendTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('OTP resent successfully')),
                                );
                              },
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF019934)),
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
                        onPressed: _isVerifying ? null : _verifyOtp,
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'Verify & Login',
                                style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
