import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/business_type.dart';
import '../../../models/registration_document.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/auth_widgets.dart';
import 'otp_screen.dart';
import 'verification_status_screen.dart';

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
  final _ownerController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _panController = TextEditingController();
  final _shopController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _cityController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _mobileError;
  String? _businessError;
  String? _ownerError;
  String? _emailError;
  String? _shopError;
  String? _deliveryError;
  String? _cityError;
  String? _stateError;
  String? _pincodeError;
  bool _stepValid = false;
  bool _capturingLocation = false;

  static const _labels = ['Mobile', 'Business', 'Address', 'Documents', 'Review'];

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, 4);
    for (final c in [
      _mobileController,
      _businessController,
      _ownerController,
      _emailController,
      _gstController,
      _shopController,
      _deliveryController,
      _cityController,
      _pincodeController,
    ]) {
      c.addListener(_recomputeValid);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthViewModel>();
      auth.startRegisterFlow();
      if (auth.mobile.isNotEmpty) _mobileController.text = auth.mobile;
      if (auth.businessName.isNotEmpty && auth.businessName != 'Bulk Buyer') {
        _businessController.text = auth.businessName;
      }
      if (auth.ownerName.isNotEmpty) _ownerController.text = auth.ownerName;
      if (auth.email.isNotEmpty) _emailController.text = auth.email;
      if (auth.gstNumber.isNotEmpty) _gstController.text = auth.gstNumber;
      if (auth.fssaiNumber.isNotEmpty) _fssaiController.text = auth.fssaiNumber;
      if (auth.panNumber.isNotEmpty) _panController.text = auth.panNumber;
      if (auth.shopAddress.isNotEmpty) _shopController.text = auth.shopAddress;
      if (auth.deliveryAddress.isNotEmpty) {
        _deliveryController.text = auth.deliveryAddress;
      }
      if (auth.city.isNotEmpty) _cityController.text = auth.city;
      if (auth.landmark.isNotEmpty) _landmarkController.text = auth.landmark;
      if (auth.pincode.isNotEmpty) _pincodeController.text = auth.pincode;
      _recomputeValid();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _mobileController,
      _businessController,
      _ownerController,
      _emailController,
      _gstController,
      _fssaiController,
      _panController,
      _shopController,
      _deliveryController,
      _cityController,
      _landmarkController,
      _pincodeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isValidEmail(String value) {
    if (value.trim().isEmpty) return true;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  void _syncAuthDraft() {
    final auth = context.read<AuthViewModel>();
    auth.setMobile(_mobileController.text.trim());
    auth.setBusinessName(_businessController.text.trim());
    auth.setOwnerName(_ownerController.text.trim());
    auth.setEmail(_emailController.text.trim());
    auth.setGstNumber(_gstController.text.trim());
    auth.setFssaiNumber(_fssaiController.text.trim());
    auth.setPanNumber(_panController.text.trim());
    auth.setShopAddress(_shopController.text.trim());
    auth.setDeliveryAddress(
      auth.sameAsShopAddress
          ? _shopController.text.trim()
          : _deliveryController.text.trim(),
    );
    auth.setCity(_cityController.text.trim());
    auth.setLandmark(_landmarkController.text.trim());
    auth.setPincode(_pincodeController.text.trim());
  }

  void _recomputeValid() {
    final auth = context.read<AuthViewModel>();
    final next = switch (_step) {
      0 => _mobileController.text.trim().length == 10,
      1 =>
        _businessController.text.trim().isNotEmpty &&
            _ownerController.text.trim().isNotEmpty &&
            _isValidEmail(_emailController.text),
      2 =>
        _shopController.text.trim().isNotEmpty &&
            (auth.sameAsShopAddress ||
                _deliveryController.text.trim().isNotEmpty) &&
            _cityController.text.trim().isNotEmpty &&
            auth.state.trim().isNotEmpty &&
            _pincodeController.text.trim().length == 6,
      3 => auth.requiredDocumentsUploaded,
      4 => auth.acceptedTerms,
      _ => false,
    };
    if (next == _stepValid) return;
    setState(() => _stepValid = next);
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
      _recomputeValid();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _continue() async {
    final auth = context.read<AuthViewModel>();
    _syncAuthDraft();

    if (_step == 0) {
      if (!_stepValid) {
        setState(() => _mobileError = 'Enter a valid 10-digit mobile number');
        return;
      }
      setState(() => _mobileError = null);
      final ok = await auth.sendOtp();
      if (!mounted) return;
      if (ok) {
        await AppPageRoute.push(context, const OtpScreen(resumeRegistration: true));
      }
      return;
    }

    if (_step == 1) {
      var ok = true;
      if (_businessController.text.trim().isEmpty) {
        _businessError = 'Business name is required';
        ok = false;
      } else {
        _businessError = null;
      }
      if (_ownerController.text.trim().isEmpty) {
        _ownerError = 'Owner name is required';
        ok = false;
      } else {
        _ownerError = null;
      }
      if (!_isValidEmail(_emailController.text)) {
        _emailError = 'Enter a valid email address';
        ok = false;
      } else {
        _emailError = null;
      }
      setState(() {});
      if (!ok) return;
      setState(() => _step = 2);
      _recomputeValid();
      return;
    }

    if (_step == 2) {
      var ok = true;
      if (_shopController.text.trim().isEmpty) {
        _shopError = 'Shop address is required';
        ok = false;
      } else {
        _shopError = null;
      }
      if (!auth.sameAsShopAddress && _deliveryController.text.trim().isEmpty) {
        _deliveryError = 'Delivery address is required';
        ok = false;
      } else {
        _deliveryError = null;
      }
      if (_cityController.text.trim().isEmpty) {
        _cityError = 'City is required';
        ok = false;
      } else {
        _cityError = null;
      }
      if (auth.state.trim().isEmpty) {
        _stateError = 'State is required';
        ok = false;
      } else {
        _stateError = null;
      }
      if (_pincodeController.text.trim().length != 6) {
        _pincodeError = 'Enter a valid 6-digit pincode';
        ok = false;
      } else {
        _pincodeError = null;
      }
      setState(() {});
      if (!ok) return;
      setState(() => _step = 3);
      _recomputeValid();
      return;
    }

    if (_step == 3) {
      if (!auth.requiredDocumentsUploaded) return;
      setState(() => _step = 4);
      _recomputeValid();
      return;
    }

    // Step 4 — Review & Submit
    if (!auth.acceptedTerms) return;
    final done = await auth.completeRegistration();
    if (!mounted) return;
    if (done) {
      await context.read<AddressViewModel>().seedFromRegistration(
            line1: auth.shopAddress,
            line2: auth.landmark.isEmpty ? null : auth.landmark,
            city: auth.city,
            pincode: auth.pincode,
          );
      if (!mounted) return;
      await AppPageRoute.pushAndRemoveUntil(
        context,
        const VerificationStatusScreen(),
      );
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _capturingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to pin your shop')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      context.read<AuthViewModel>().setGeo(pos.latitude, pos.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture location: $e')),
      );
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }

  Future<void> _pickDocument(RegistrationDocumentType type) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            const SizedBox(height: 16),
            Text(type.label, style: AppTextStyles.display(fontSize: 18)),
            const SizedBox(height: 12),
            _DocSheetTile(
              icon: Icons.photo_camera_rounded,
              label: 'Take Photo',
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            _DocSheetTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            _DocSheetTile(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Upload PDF',
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    String? path;
    if (choice == 'pdf') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      path = result?.files.single.path;
    } else {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      path = file?.path;
    }
    if (path == null || !mounted) return;
    context.read<AuthViewModel>().setDocument(type, path);
    _recomputeValid();
  }

  String get _title => switch (_step) {
        0 => 'Verify your mobile',
        1 => 'Tell us about your business',
        2 => 'Shop & delivery address',
        3 => 'Upload documents',
        _ => 'Review & submit',
      };

  String get _subtitle => switch (_step) {
        0 => 'We’ll send a one-time code to confirm it’s you.',
        1 => 'This helps us show the right wholesale catalogue.',
        2 => 'Used for COD deliveries to your business.',
        3 => 'Aadhaar and Shop Front Photo are required to continue.',
        _ => 'Confirm details before we send your application for review.',
      };

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
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 4),
                    _ProgressPills(step: _step, labels: _labels),
                    const SizedBox(height: 24),
                    Text(_title, style: AppTextStyles.display(fontSize: 24, height: 1.2)),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: AppTextStyles.body(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: switch (_step) {
                          0 => _MobileStep(
                              controller: _mobileController,
                              error: _mobileError,
                              onChanged: (_) {
                                if (_mobileError != null) {
                                  setState(() => _mobileError = null);
                                }
                              },
                            ),
                          1 => _BusinessStep(
                              businessController: _businessController,
                              ownerController: _ownerController,
                              emailController: _emailController,
                              gstController: _gstController,
                              fssaiController: _fssaiController,
                              panController: _panController,
                              businessError: _businessError,
                              ownerError: _ownerError,
                              emailError: _emailError,
                              selectedTypeId: auth.businessTypeId,
                              onType: (id) {
                                auth.setBusinessTypeId(id);
                                _recomputeValid();
                              },
                              onChanged: () {
                                setState(() {
                                  _businessError = null;
                                  _ownerError = null;
                                  _emailError = null;
                                });
                                _recomputeValid();
                              },
                            ),
                          2 => _AddressStep(
                              shopController: _shopController,
                              deliveryController: _deliveryController,
                              cityController: _cityController,
                              landmarkController: _landmarkController,
                              pincodeController: _pincodeController,
                              sameAsShop: auth.sameAsShopAddress,
                              selectedState: auth.state,
                              shopError: _shopError,
                              deliveryError: _deliveryError,
                              cityError: _cityError,
                              stateError: _stateError,
                              pincodeError: _pincodeError,
                              geoLat: auth.geoLat,
                              geoLng: auth.geoLng,
                              capturingLocation: _capturingLocation,
                              onSameAsShop: (v) {
                                auth.setSameAsShopAddress(v);
                                if (v) {
                                  _deliveryController.text = _shopController.text;
                                }
                                _recomputeValid();
                              },
                              onState: (s) {
                                auth.setStateName(s);
                                setState(() => _stateError = null);
                                _recomputeValid();
                              },
                              onCaptureLocation: _captureLocation,
                              onChanged: () {
                                setState(() {
                                  _shopError = null;
                                  _deliveryError = null;
                                  _cityError = null;
                                  _pincodeError = null;
                                });
                                if (auth.sameAsShopAddress) {
                                  _deliveryController.text = _shopController.text;
                                }
                                _recomputeValid();
                              },
                            ),
                          3 => _DocumentsStep(
                              hasGstin: _gstController.text.trim().isNotEmpty ||
                                  auth.gstNumber.trim().isNotEmpty,
                              documents: auth.documents,
                              uploaded: auth.uploadedDocumentCount,
                              total: auth.visibleDocumentCount,
                              onUpload: _pickDocument,
                            ),
                          _ => _ReviewStep(
                              auth: auth,
                              mobile: _mobileController.text.trim(),
                              onEdit: (step) {
                                setState(() => _step = step);
                                _recomputeValid();
                              },
                              onTerms: (v) {
                                auth.setAcceptedTerms(v);
                                _recomputeValid();
                              },
                            ),
                        },
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
              label: _step == 4 ? 'Submit Application' : 'Continue',
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
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 6),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    fontSize: 9,
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
    required this.ownerController,
    required this.emailController,
    required this.gstController,
    required this.fssaiController,
    required this.panController,
    required this.businessError,
    required this.ownerError,
    required this.emailError,
    required this.selectedTypeId,
    required this.onType,
    required this.onChanged,
  });

  final TextEditingController businessController;
  final TextEditingController ownerController;
  final TextEditingController emailController;
  final TextEditingController gstController;
  final TextEditingController fssaiController;
  final TextEditingController panController;
  final String? businessError;
  final String? ownerError;
  final String? emailError;
  final String selectedTypeId;
  final ValueChanged<String> onType;
  final VoidCallback onChanged;

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
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('Owner Name'),
        const SizedBox(height: 8),
        PillTextField(
          controller: ownerController,
          hint: 'Full name of owner',
          textCapitalization: TextCapitalization.words,
          errorText: ownerError,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('Email', optional: true),
        const SizedBox(height: 8),
        PillTextField(
          controller: emailController,
          hint: 'orders@yourshop.com',
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
          onChanged: (_) => onChanged(),
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
          children: BusinessTypes.all.map((t) {
            final selected = t.id == selectedTypeId;
            return PressableScale(
              onTap: () => onType(t.id),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.ease,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                  t.label,
                  style: AppTextStyles.body(
                    fontSize: 12,
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
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('FSSAI License Number', optional: true),
        const SizedBox(height: 8),
        PillTextField(
          controller: fssaiController,
          hint: '12345678901234',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('PAN Number', optional: true),
        const SizedBox(height: 8),
        PillTextField(
          controller: panController,
          hint: 'ABCDE1234F',
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [LengthLimitingTextInputFormatter(10)],
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.shopController,
    required this.deliveryController,
    required this.cityController,
    required this.landmarkController,
    required this.pincodeController,
    required this.sameAsShop,
    required this.selectedState,
    required this.shopError,
    required this.deliveryError,
    required this.cityError,
    required this.stateError,
    required this.pincodeError,
    required this.geoLat,
    required this.geoLng,
    required this.capturingLocation,
    required this.onSameAsShop,
    required this.onState,
    required this.onCaptureLocation,
    required this.onChanged,
  });

  final TextEditingController shopController;
  final TextEditingController deliveryController;
  final TextEditingController cityController;
  final TextEditingController landmarkController;
  final TextEditingController pincodeController;
  final bool sameAsShop;
  final String selectedState;
  final String? shopError;
  final String? deliveryError;
  final String? cityError;
  final String? stateError;
  final String? pincodeError;
  final double? geoLat;
  final double? geoLng;
  final bool capturingLocation;
  final ValueChanged<bool> onSameAsShop;
  final ValueChanged<String> onState;
  final VoidCallback onCaptureLocation;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final hasGeo = geoLat != null && geoLng != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthFieldLabel('Shop Address'),
        const SizedBox(height: 8),
        PillTextField(
          controller: shopController,
          hint: 'Shop no., building, street',
          tall: true,
          maxLines: 2,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          errorText: shopError,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => onSameAsShop(!sameAsShop),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Row(
            children: [
              Checkbox(
                value: sameAsShop,
                activeColor: AppColors.violet,
                onChanged: (v) => onSameAsShop(v ?? false),
              ),
              Expanded(
                child: Text(
                  'Same as Shop Address',
                  style: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const AuthFieldLabel('Delivery Address'),
        const SizedBox(height: 8),
        PillTextField(
          controller: deliveryController,
          hint: 'Where COD orders should arrive',
          tall: true,
          maxLines: 2,
          minLines: 2,
          enabled: !sameAsShop,
          textCapitalization: TextCapitalization.sentences,
          errorText: deliveryError,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('City'),
        const SizedBox(height: 8),
        PillTextField(
          controller: cityController,
          hint: 'Bengaluru',
          textCapitalization: TextCapitalization.words,
          errorText: cityError,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('State'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: stateError != null ? AppColors.alert : AppColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: IndianStates.all.contains(selectedState)
                  ? selectedState
                  : IndianStates.all.first,
              isExpanded: true,
              items: IndianStates.all
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onState(v);
              },
            ),
          ),
        ),
        if (stateError != null) ...[
          const SizedBox(height: 6),
          Text(stateError!, style: AppTextStyles.body(fontSize: 12, color: AppColors.alert)),
        ],
        const SizedBox(height: 16),
        const AuthFieldLabel('Landmark', optional: true),
        const SizedBox(height: 8),
        PillTextField(
          controller: landmarkController,
          hint: 'Near mandi gate',
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        PressableScale(
          onTap: capturingLocation ? null : onCaptureLocation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: hasGeo ? AppColors.success : AppColors.violet,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pin your location on map',
                        style: AppTextStyles.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        capturingLocation
                            ? 'Capturing GPS…'
                            : hasGeo
                                ? 'Location captured'
                                : 'Tap to capture device GPS (map UI later)',
                        style: AppTextStyles.body(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                if (capturingLocation)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet),
                  )
                else if (hasGeo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      'Captured',
                      style: AppTextStyles.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({
    required this.hasGstin,
    required this.documents,
    required this.uploaded,
    required this.total,
    required this.onUpload,
  });

  final bool hasGstin;
  final Map<String, String> documents;
  final int uploaded;
  final int total;
  final ValueChanged<RegistrationDocumentType> onUpload;

  @override
  Widget build(BuildContext context) {
    final types = RegistrationDocumentType.visibleTypes(hasGstin: hasGstin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$uploaded of $total uploaded (2 required)',
          style: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        ...types.map((type) {
          final path = documents[type.id];
          final uploadedDoc = path != null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PressableScale(
              onTap: () => onUpload(type),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: uploadedDoc ? AppColors.success : AppColors.line,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: uploadedDoc
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.section,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        uploadedDoc ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                        color: uploadedDoc ? AppColors.success : AppColors.violet,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  type.label,
                                  style: AppTextStyles.body(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (type.isRequired)
                                Text(
                                  'Required',
                                  style: AppTextStyles.body(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.rust,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            uploadedDoc ? 'Uploaded' : 'Not uploaded',
                            style: AppTextStyles.body(
                              fontSize: 12,
                              color: uploadedDoc ? AppColors.success : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.auth,
    required this.mobile,
    required this.onEdit,
    required this.onTerms,
  });

  final AuthViewModel auth;
  final String mobile;
  final ValueChanged<int> onEdit;
  final ValueChanged<bool> onTerms;

  @override
  Widget build(BuildContext context) {
    final docs = RegistrationDocumentType.visibleTypes(
      hasGstin: auth.gstNumber.trim().isNotEmpty,
    );
    final uploadedLabels = docs
        .where((t) => auth.documents.containsKey(t.id))
        .map((t) => t.label)
        .toList();

    return Column(
      children: [
        _ReviewCard(
          title: 'Mobile',
          onEdit: () => onEdit(0),
          rows: [('Number', '+91 $mobile')],
        ),
        _ReviewCard(
          title: 'Business Info',
          onEdit: () => onEdit(1),
          rows: [
            ('Business', auth.businessName),
            ('Owner', auth.ownerName),
            ('Type', auth.businessType),
            if (auth.email.isNotEmpty) ('Email', auth.email),
            if (auth.gstNumber.isNotEmpty) ('GSTIN', auth.gstNumber),
            if (auth.fssaiNumber.isNotEmpty) ('FSSAI', auth.fssaiNumber),
            if (auth.panNumber.isNotEmpty) ('PAN', auth.panNumber),
          ],
        ),
        _ReviewCard(
          title: 'Address',
          onEdit: () => onEdit(2),
          rows: [
            ('Shop', auth.shopAddress),
            ('Delivery', auth.sameAsShopAddress ? auth.shopAddress : auth.deliveryAddress),
            ('City', auth.city),
            ('State', auth.state),
            if (auth.landmark.isNotEmpty) ('Landmark', auth.landmark),
            ('Pincode', auth.pincode),
            if (auth.geoLat != null)
              (
                'GPS',
                '${auth.geoLat!.toStringAsFixed(5)}, ${auth.geoLng!.toStringAsFixed(5)}'
              ),
          ],
        ),
        _ReviewCard(
          title: 'Documents',
          onEdit: () => onEdit(3),
          rows: [
            (
              'Uploaded',
              uploadedLabels.isEmpty ? 'None' : uploadedLabels.join(', '),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => onTerms(!auth.acceptedTerms),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: auth.acceptedTerms,
                activeColor: AppColors.violet,
                onChanged: (v) => onTerms(v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy for wholesale COD ordering on VeggiiCart.',
                    style: AppTextStyles.body(fontSize: 13, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  final String title;
  final VoidCallback onEdit;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'Edit',
                  style: AppTextStyles.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 78,
                    child: Text(
                      r.$1,
                      style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.$2,
                      style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocSheetTile extends StatelessWidget {
  const _DocSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.violet),
      title: Text(label, style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
