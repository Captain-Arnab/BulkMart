import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import 'otp_screen.dart';
import 'registration_success_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.initialStep = 0});

  final int initialStep;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late int _step;
  final _mobileController = TextEditingController();
  final _businessController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _mobileError;
  String? _businessError;
  String? _addressError;
  String? _pincodeError;
  bool _stepValid = false;

  static const _types = ['Wholesaler', 'Restaurant', 'Retailer', 'Other'];
  static const _labels = ['Mobile', 'Business Info', 'Address'];

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, 2);
    _mobileController.addListener(_recomputeValid);
    _businessController.addListener(_recomputeValid);
    _addressController.addListener(_recomputeValid);
    _pincodeController.addListener(_recomputeValid);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthViewModel>();
      auth.startRegisterFlow();
      if (auth.mobile.isNotEmpty) {
        _mobileController.text = auth.mobile;
      }
      if (auth.businessName.isNotEmpty && auth.businessName != 'Bulk Buyer') {
        _businessController.text = auth.businessName;
      }
      _recomputeValid();
    });
  }

  @override
  void dispose() {
    _mobileController.removeListener(_recomputeValid);
    _businessController.removeListener(_recomputeValid);
    _addressController.removeListener(_recomputeValid);
    _pincodeController.removeListener(_recomputeValid);
    _mobileController.dispose();
    _businessController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _recomputeValid() {
    final next = switch (_step) {
      0 => _mobileController.text.trim().length == 10,
      1 => _businessController.text.trim().isNotEmpty,
      2 =>
        _addressController.text.trim().isNotEmpty &&
            _pincodeController.text.trim().length == 6,
      _ => false,
    };
    if (next == _stepValid) return;
    setState(() => _stepValid = next);
  }

  Future<void> _continue() async {
    final auth = context.read<AuthViewModel>();

    if (_step == 0) {
      if (!_stepValid) {
        setState(() => _mobileError = 'Enter a valid 10-digit mobile number');
        return;
      }
      setState(() => _mobileError = null);
      auth.setMobile(_mobileController.text.trim());
      final ok = await auth.sendOtp();
      if (!mounted) return;
      if (ok) {
        await AppPageRoute.push(context, const OtpScreen(resumeRegistration: true));
      }
      return;
    }

    if (_step == 1) {
      if (!_stepValid) {
        setState(() => _businessError = 'Business name is required');
        return;
      }
      setState(() {
        _businessError = null;
        _step = 2;
      });
      auth.setBusinessName(_businessController.text.trim());
      auth.setGstNumber(_gstController.text.trim());
      _recomputeValid();
      return;
    }

    // Step 2 — address
    var ok = true;
    if (_addressController.text.trim().isEmpty) {
      _addressError = 'Delivery address is required';
      ok = false;
    } else {
      _addressError = null;
    }
    if (_pincodeController.text.trim().length != 6) {
      _pincodeError = 'Enter a valid 6-digit pincode';
      ok = false;
    } else {
      _pincodeError = null;
    }
    setState(() {});
    if (!ok) return;

    auth.setAddress(_addressController.text.trim());
    auth.setPincode(_pincodeController.text.trim());
    auth.setBusinessName(_businessController.text.trim().isEmpty
        ? auth.businessName
        : _businessController.text.trim());
    auth.setGstNumber(_gstController.text.trim());

    final done = await auth.completeRegistration();
    if (!mounted) return;
    if (done) {
      await AppPageRoute.pushAndRemoveUntil(context, const RegistrationSuccessScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return AuthScaffold(
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_step > 1 || (_step == 1 && widget.initialStep == 1)) {
                          if (_step > 1) {
                            setState(() => _step = 1);
                            _recomputeValid();
                          } else {
                            Navigator.of(context).pop();
                          }
                        } else if (_step > 0) {
                          setState(() => _step = _step - 1);
                          _recomputeValid();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 4),
                    _ProgressPills(step: _step, labels: _labels),
                    const SizedBox(height: 28),
                    Text(
                      _step == 0
                          ? 'Verify your mobile'
                          : _step == 1
                              ? 'Tell us about your business'
                              : 'Where should we deliver?',
                      style: AppTextStyles.display(fontSize: 26, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _step == 0
                          ? 'We’ll send a one-time code to confirm it’s you.'
                          : _step == 1
                              ? 'This helps us show the right wholesale catalogue.'
                              : 'Used for COD deliveries to your business.',
                      style: AppTextStyles.body(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _step == 0
                            ? _MobileStep(
                                controller: _mobileController,
                                error: _mobileError,
                                onChanged: (_) {
                                  if (_mobileError != null) {
                                    setState(() => _mobileError = null);
                                  }
                                },
                              )
                            : _step == 1
                                ? _BusinessStep(
                                    businessController: _businessController,
                                    gstController: _gstController,
                                    businessError: _businessError,
                                    selectedType: auth.businessType,
                                    onType: (t) => auth.setBusinessType(t),
                                    onBusinessChanged: () {
                                      if (_businessError != null) {
                                        setState(() => _businessError = null);
                                      }
                                    },
                                  )
                                : _AddressStep(
                                    addressController: _addressController,
                                    pincodeController: _pincodeController,
                                    addressError: _addressError,
                                    pincodeError: _pincodeError,
                                    onChanged: () {
                                      if (_addressError != null || _pincodeError != null) {
                                        setState(() {
                                          _addressError = null;
                                          _pincodeError = null;
                                        });
                                      }
                                    },
                                  ),
                      ),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.error!,
                        style: AppTextStyles.body(fontSize: 13, color: AppColors.alert),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.92),
              boxShadow: AppShadows.soft(opacity: 0.06),
            ),
            child: AuthPrimaryButton(
              label: _step == 2 ? 'Create account' : 'Continue',
              isLoading: auth.isLoading,
              enabled: _stepValid,
              onPressed: _continue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPills extends StatelessWidget {
  const _ProgressPills({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final completed = i < step;
        final current = i == step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.ease,
                  height: 6,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.success
                        : current
                            ? AppColors.violet
                            : AppColors.line,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: AppTextStyles.body(
                    fontSize: 10,
                    fontWeight: current || completed ? FontWeight.w700 : FontWeight.w500,
                    color: completed
                        ? AppColors.success
                        : current
                            ? AppColors.violet
                            : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MobileStep extends StatelessWidget {
  const _MobileStep({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthFieldLabel('Mobile number'),
        const SizedBox(height: 8),
        PillTextField(
          controller: controller,
          hint: '9xxxxxxxxx',
          keyboardType: TextInputType.phone,
          prefix: const CountryCodeChip(),
          errorText: error,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({
    required this.businessController,
    required this.gstController,
    required this.businessError,
    required this.selectedType,
    required this.onType,
    required this.onBusinessChanged,
  });

  final TextEditingController businessController;
  final TextEditingController gstController;
  final String? businessError;
  final String selectedType;
  final ValueChanged<String> onType;
  final VoidCallback onBusinessChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthFieldLabel('Business / Shop Name'),
        const SizedBox(height: 8),
        PillTextField(
          controller: businessController,
          hint: 'e.g. Sharma Restaurant Supplies',
          textCapitalization: TextCapitalization.words,
          errorText: businessError,
          onChanged: (_) => onBusinessChanged(),
        ),
        const SizedBox(height: 20),
        Text(
          'BUSINESS TYPE',
          style: AppTextStyles.label(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _RegistrationScreenState._types.map((t) {
            final selected = t == selectedType;
            return PressableScale(
              onTap: () => onType(t),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.ease,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.violet : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: selected ? AppColors.violet : AppColors.line,
                  ),
                  boxShadow: selected
                      ? AppShadows.soft(color: AppColors.violet, opacity: 0.2)
                      : null,
                ),
                child: Text(
                  t,
                  style: AppTextStyles.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const AuthFieldLabel('GSTIN', optional: true),
        const SizedBox(height: 8),
        PillTextField(
          controller: gstController,
          hint: '22AAAAA0000A1Z5',
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.addressController,
    required this.pincodeController,
    required this.addressError,
    required this.pincodeError,
    required this.onChanged,
  });

  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final String? addressError;
  final String? pincodeError;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthFieldLabel('Delivery Address'),
        const SizedBox(height: 8),
        PillTextField(
          controller: addressController,
          hint: 'Shop no., street, landmark, city',
          tall: true,
          maxLines: 3,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          errorText: addressError,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 20),
        const AuthFieldLabel('Pincode'),
        const SizedBox(height: 8),
        PillTextField(
          controller: pincodeController,
          hint: '560001',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          errorText: pincodeError,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
