import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/auth_repository.dart';

enum _ForgotStep { email, otp, reset }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authRepo = LiveAuthRepository();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _ForgotStep _step = _ForgotStep.email;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _resendSeconds = 0;

  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _confirmError;

  static const _green = Color(0xFF019934);

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail.trim();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    _emailError = null;
    _otpError = null;
    _passwordError = null;
    _confirmError = null;
  }

  void _startResendCooldown() {
    setState(() => _resendSeconds = 30);
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

  bool _validateEmailLocal() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) {
      setState(() => _emailError = 'Enter a valid email address');
      return false;
    }
    return true;
  }

  bool _validateOtpLocal() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _otpError = 'OTP is required');
      return false;
    }
    if (otp.length < 4) {
      setState(() => _otpError = 'Enter the OTP sent to your email');
      return false;
    }
    return true;
  }

  bool _validatePasswordLocal() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    var ok = true;
    if (password.isEmpty) {
      _passwordError = 'New password is required';
      ok = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      ok = false;
    }
    if (confirm.isEmpty) {
      _confirmError = 'Please confirm your password';
      ok = false;
    } else if (password != confirm) {
      _confirmError = 'Passwords do not match';
      ok = false;
    }
    setState(() {});
    return ok;
  }

  void _mapApiErrorToField(String message) {
    final lower = message.toLowerCase();
    if (_step == _ForgotStep.email ||
        lower.contains('email') ||
        lower.contains('account')) {
      _emailError = message;
    } else if (_step == _ForgotStep.otp ||
        lower.contains('otp') ||
        lower.contains('expired') ||
        lower.contains('invalid or')) {
      _otpError = message;
    } else if (lower.contains('password') || lower.contains('weak')) {
      _passwordError = message;
    } else if (_step == _ForgotStep.reset) {
      _passwordError = message;
    } else {
      _otpError = message;
    }
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    _clearFieldErrors();
    if (!_validateEmailLocal()) return;

    setState(() => _submitting = true);
    final result = await _authRepo.forgotPasswordSendOtp(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result is ApiFailure<void>) {
      setState(() => _mapApiErrorToField(result.message));
      return;
    }

    setState(() => _step = _ForgotStep.otp);
    _startResendCooldown();
    if (isResend) {
      await SweetAlert.success(context, message: 'OTP resent to your email');
    }
  }

  Future<void> _verifyOtp() async {
    _clearFieldErrors();
    if (!_validateOtpLocal()) return;

    setState(() => _submitting = true);
    final result = await _authRepo.forgotPasswordVerifyOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result is ApiFailure<void>) {
      setState(() => _mapApiErrorToField(result.message));
      return;
    }

    setState(() => _step = _ForgotStep.reset);
  }

  Future<void> _resetPassword() async {
    _clearFieldErrors();
    if (!_validatePasswordLocal()) return;

    setState(() => _submitting = true);
    final result = await _authRepo.forgotPasswordReset(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result is ApiFailure<void>) {
      setState(() => _mapApiErrorToField(result.message));
      return;
    }

    await SweetAlert.success(
      context,
      message: 'Password reset successfully. Please sign in with your new password.',
      onConfirm: () {
        if (mounted) Navigator.pop(context, true);
      },
    );
  }

  Future<void> _onPrimaryAction() async {
    switch (_step) {
      case _ForgotStep.email:
        await _sendOtp();
      case _ForgotStep.otp:
        await _verifyOtp();
      case _ForgotStep.reset:
        await _resetPassword();
    }
  }

  String get _title {
    switch (_step) {
      case _ForgotStep.email:
        return 'Forgot Password';
      case _ForgotStep.otp:
        return 'Verify OTP';
      case _ForgotStep.reset:
        return 'Reset Password';
    }
  }

  String get _subtitle {
    switch (_step) {
      case _ForgotStep.email:
        return 'Enter your registered email to receive an OTP';
      case _ForgotStep.otp:
        return 'We sent a code to ${_emailController.text.trim()}';
      case _ForgotStep.reset:
        return 'Choose a new password for your account';
    }
  }

  String get _buttonLabel {
    switch (_step) {
      case _ForgotStep.email:
        return 'Send OTP';
      case _ForgotStep.otp:
        return 'Verify OTP';
      case _ForgotStep.reset:
        return 'Reset Password';
    }
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    String? errorText,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.green.shade400, size: 20),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      );

  Widget _buildStepFields() {
    switch (_step) {
      case _ForgotStep.email:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(fontSize: 14),
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
              decoration: _decoration(
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                errorText: _emailError,
              ),
            ),
          ],
        );
      case _ForgotStep.otp:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('OTP'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 14, letterSpacing: 4),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              onChanged: (_) {
                if (_otpError != null) setState(() => _otpError = null);
              },
              decoration: _decoration(
                hint: 'Enter OTP',
                icon: Icons.pin_outlined,
                errorText: _otpError,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (_resendSeconds > 0 || _submitting)
                    ? null
                    : () => _sendOtp(isResend: true),
                child: Text(
                  _resendSeconds > 0
                      ? 'Resend OTP in ${_resendSeconds}s'
                      : 'Resend OTP',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _resendSeconds > 0
                        ? Colors.grey.shade500
                        : _green,
                  ),
                ),
              ),
            ),
          ],
        );
      case _ForgotStep.reset:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('New Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.poppins(fontSize: 14),
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
              decoration: _decoration(
                hint: 'At least 6 characters',
                icon: Icons.lock_outline,
                errorText: _passwordError,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _label('Confirm Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              style: GoogleFonts.poppins(fontSize: 14),
              onChanged: (_) {
                if (_confirmError != null) {
                  setState(() => _confirmError = null);
                }
              },
              decoration: _decoration(
                hint: 'Re-enter new password',
                icon: Icons.lock_outline,
                errorText: _confirmError,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              _title,
              style: GoogleFonts.rubik(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(step: _step),
                    const SizedBox(height: 22),
                    _buildStepFields(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _submitting ? null : _onPrimaryAction,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _buttonLabel,
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (_step != _ForgotStep.email) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _submitting
                              ? null
                              : () {
                                  setState(() {
                                    _clearFieldErrors();
                                    if (_step == _ForgotStep.reset) {
                                      _step = _ForgotStep.otp;
                                    } else {
                                      _step = _ForgotStep.email;
                                    }
                                  });
                                },
                          child: Text(
                            'Back',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _green,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _ForgotStep step;

  int get _index {
    switch (step) {
      case _ForgotStep.email:
        return 0;
      case _ForgotStep.otp:
        return 1;
      case _ForgotStep.reset:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Email', 'OTP', 'Password'];
    return Row(
      children: List.generate(3, (i) {
        final active = i <= _index;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF019934)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active
                      ? const Color(0xFF019934)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
