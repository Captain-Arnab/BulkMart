import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import '../home/main_shell.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.resumeRegistration = false});

  /// When true, successful verify continues registration instead of Home.
  final bool resumeRegistration;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());
  int _seconds = 28;
  Timer? _timer;
  bool _showSuccessFlash = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
      if (!kDebugMode) return;
      final hint = context.read<AuthViewModel>().lastDevOtp;
      if (hint != null && hint.length == _length) {
        for (var i = 0; i < _length; i++) {
          _controllers[i].text = hint[i];
        }
        setState(() {});
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 28);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _onChanged(int index, String value) async {
    if (value.length > 1) {
      // Paste support
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, _length) - 1;
      if (next >= 0) _focusNodes[next.clamp(0, _length - 1)].requestFocus();
      setState(() {});
      if (digits.length >= _length) await _verify();
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
    if (_otp.length == _length) await _verify();
  }

  Future<void> _verify() async {
    if (_submitting || _otp.length != _length) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthViewModel>();
    final persist = !widget.resumeRegistration && auth.authFlow != 'register';
    final ok = await auth.verifyOtp(_otp, persistSession: persist);
    if (!mounted) return;

    if (!ok) {
      setState(() => _submitting = false);
      if (auth.isAlreadyRegisteredError) {
        auth.startLoginFlow();
        await AppPageRoute.pushAndRemoveUntil(
          context,
          LoginScreen(
            initialMobile: auth.mobile,
            alreadyRegisteredHint: true,
          ),
        );
        return;
      }
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      return;
    }

    setState(() => _showSuccessFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    final isRegister = widget.resumeRegistration || auth.authFlow == 'register';
    if (isRegister) {
      await AppPageRoute.pushReplacement(
        context,
        const RegistrationScreen(initialStep: 1),
      );
    } else {
      await AppPageRoute.pushAndRemoveUntil(context, const MainShell());
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthViewModel>();
    final ok = await auth.resendOtp();
    if (!mounted) return;
    if (!ok && auth.isAlreadyRegisteredError) {
      auth.startLoginFlow();
      await AppPageRoute.pushAndRemoveUntil(
        context,
        LoginScreen(
          initialMobile: auth.mobile,
          alreadyRegisteredHint: true,
        ),
      );
      return;
    }
    _startTimer();
    final hint = auth.lastDevOtp;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hint != null && kDebugMode
              ? 'OTP sent to your mobile (dev: $hint)'
              : !ok && auth.error != null
                  ? auth.error!
                  : 'OTP sent to your mobile',
        ),
        backgroundColor: !ok ? AppColors.alert : AppColors.violet,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok && kDebugMode && hint != null && hint.length == _length) {
      for (var i = 0; i < _length; i++) {
        _controllers[i].text = hint[i];
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final masked = auth.mobile.length >= 4
        ? '******${auth.mobile.substring(auth.mobile.length - 4)}'
        : auth.mobile;

    return AuthScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter OTP',
                style: AppTextStyles.display(fontSize: 28),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'OTP sent to +91 $masked',
                style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
              ).animate().fadeIn(delay: 60.ms, duration: 200.ms),
              if (kDebugMode && auth.lastDevOtp != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.mustard.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.mustard.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    'Dev OTP (SMS fallback): ${auth.lastDevOtp}',
                    style: AppTextStyles.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8A5C13),
                    ),
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 200.ms),
              ],
              const SizedBox(height: 36),
              AnimatedSwitcher(
                duration: AppMotion.normal,
                child: _showSuccessFlash
                    ? Center(
                        key: const ValueKey('ok'),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.6, 0.6),
                              end: const Offset(1, 1),
                              duration: 280.ms,
                              curve: AppMotion.pop,
                            ),
                      )
                    : Row(
                        key: const ValueKey('boxes'),
                        children: [
                          for (var i = 0; i < _length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: _OtpDigitBox(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                onChanged: (v) async {
                                  if (v.isEmpty) {
                                    if (i > 0) {
                                      _focusNodes[i - 1].requestFocus();
                                    }
                                    setState(() {});
                                    return;
                                  }
                                  await _onChanged(i, v);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (auth.error != null && !_showSuccessFlash) ...[
                const SizedBox(height: 14),
                Text(
                  auth.error!,
                  style: AppTextStyles.body(fontSize: 13, color: AppColors.alert),
                ),
              ],
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: 'Verify OTP',
                isLoading: _submitting || auth.isLoading,
                enabled: _otp.length == _length && !_showSuccessFlash,
                onPressed: _verify,
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: _seconds > 0
                      ? Text(
                          'Resend OTP in 0:${_seconds.toString().padLeft(2, '0')}',
                          key: const ValueKey('count'),
                          style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                        )
                      : GestureDetector(
                          key: const ValueKey('resend'),
                          onTap: auth.isLoading ? null : _resend,
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.violet,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single OTP digit cell — equal [Expanded] slots + identical square size;
/// focus scale stays inside so gaps remain uniform.
class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    final focused = focusNode.hasFocus;

    final Color borderColor;
    final double borderWidth;
    if (focused) {
      borderColor = AppColors.green;
      borderWidth = 2;
    } else {
      borderColor = AppColors.border;
      borderWidth = 1.5;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedScale(
        scale: focused ? 1.05 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.pop,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.ease,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.18),
                      blurRadius: 12,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            cursorColor: AppColors.green,
            style: AppTextStyles.price(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          )
              .animate(key: ValueKey('otp_pop_${controller.text}'))
              .scale(
                begin: filled ? const Offset(0.72, 0.72) : const Offset(1, 1),
                end: const Offset(1, 1),
                duration: filled ? 180.ms : 0.ms,
                curve: AppMotion.pop,
              ),
        ),
      ),
    );
  }
}
