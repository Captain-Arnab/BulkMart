import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui/app_motion.dart';
import '../../core/ui/pressable_scale.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Soft green-tinted auth background used across Login / OTP / Register.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.greenSoft,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: child,
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: AppTextStyles.label(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0.6,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 8),
          Text(
            'optional',
            style: AppTextStyles.body(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class PillTextField extends StatefulWidget {
  const PillTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.maxLines = 1,
    this.minLines,
    this.errorText,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.tall = false,
    this.enabled = true,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final int maxLines;
  final int? minLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final bool tall;
  final bool enabled;
  final bool readOnly;

  @override
  State<PillTextField> createState() => _PillTextFieldState();
}

class _PillTextFieldState extends State<PillTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _ownsFocus = false;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _ownsFocus = widget.focusNode == null;
    _focus.addListener(() => setState(() {}));
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant PillTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null &&
        widget.errorText!.isNotEmpty &&
        oldWidget.errorText != widget.errorText) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.tall ? AppRadii.md : AppRadii.pill;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_shake.value);
        final dx = (t < 0.25)
            ? -4
            : (t < 0.5)
                ? 4
                : (t < 0.75)
                    ? -2
                    : 0.0;
        return Transform.translate(offset: Offset(dx.toDouble(), 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.ease,
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.white : AppColors.section,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: hasError
                    ? AppColors.alert
                    : focused && widget.enabled
                        ? AppColors.violet
                        : AppColors.line,
                width: focused || hasError ? 1.6 : 1,
              ),
              boxShadow: focused && widget.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Row(
                crossAxisAlignment:
                    widget.tall ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (widget.prefix != null) widget.prefix!,
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      textCapitalization: widget.textCapitalization,
                      onChanged: widget.onChanged,
                      cursorColor: AppColors.violet,
                      style: AppTextStyles.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.enabled ? AppColors.ink : AppColors.muted,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppTextStyles.body(fontSize: 15, color: AppColors.muted),
                        // Theme sets filled:true — keep fill transparent so the
                        // outer pill clips cleanly (no sharp white rectangle).
                        filled: true,
                        fillColor: Colors.transparent,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.prefix == null ? 18 : 8,
                          vertical: widget.tall ? 16 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              widget.errorText!,
              style: AppTextStyles.body(fontSize: 12, color: AppColors.alert),
            ),
          ],
        ],
      ),
    );
  }
}

class CountryCodeChip extends StatelessWidget {
  const CountryCodeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '+91',
        style: AppTextStyles.body(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.violet,
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading && onPressed != null;

    return PressableScale(
      enabled: active,
      onTap: active ? onPressed : null,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.ease,
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.violet : AppColors.muted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: active ? AppShadows.button(color: AppColors.violet) : null,
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('load'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: AppTextStyles.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
