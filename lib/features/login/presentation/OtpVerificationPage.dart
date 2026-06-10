import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/data/demo_auth.dart';
import 'package:urban_roots/core/notifications/post_login_device_sync.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/models/login_response.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

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
      await SweetAlert.warning(context, message: 'Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final inferredRole = _resolveRole() ?? AuthRole.user;

      final result = await UrbanRootsApi.instance.auth.otpLogin(
        phone: widget.identifier.replaceAll(RegExp(r'\D'), ''),
        otp: _otpController.text,
      );

      if (result is ApiFailure<Map<String, dynamic>>) {
        if (!mounted) return;
        await SweetAlert.error(context, message: result.message);
        return;
      }

      final data = (result as ApiSuccess<Map<String, dynamic>>).data;
      final token = extractAuthToken(data);
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        await SweetAlert.error(
          context,
          message: 'Login succeeded but no auth token was returned. Please try again.',
        );
        return;
      }

      final response = LoginResponse(
        token: token,
        role: inferredRole,
        userId: extractUserId(data),
      );

      await AuthSession.instance.save(
        token: response.token,
        role: response.role,
        userId: response.userId,
        displayName: response.name,
      );

      // Best-effort FCM sync — failure must not block login or clear the session.
      await syncDeviceTokenAfterAuth(role: response.role);

      if (!mounted) return;
      navigateAfterLogin(context, response.role);
    } catch (e) {
      if (!mounted) return;
      await SweetAlert.error(context, message: 'Login failed: $e');
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
                              onPressed: () async {
                                setState(() => _resendSeconds = 30);
                                _startResendTimer();
                                final result = await UrbanRootsApi.instance.auth.sendLoginOtp(
                                  phone: widget.identifier.replaceAll(RegExp(r'\D'), ''),
                                );
                                if (!mounted) return;
                                if (result is ApiFailure<Map<String, dynamic>>) {
                                  await SweetAlert.error(context, message: result.message);
                                } else {
                                  await SweetAlert.success(context, message: 'OTP resent successfully');
                                }
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
