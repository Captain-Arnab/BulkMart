import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/business_type.dart';
import '../../../models/kyc_status.dart';
import '../../../models/registration_document.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/document_source_sheet.dart';
import '../../widgets/profile_avatar.dart';
import '../auth/verification_status_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _scrollController = ScrollController();
  final _documentsKey = GlobalKey();

  late final TextEditingController _business;
  late final TextEditingController _owner;
  late final TextEditingController _email;
  late final TextEditingController _gst;
  late final TextEditingController _fssai;
  late final TextEditingController _pan;
  late final TextEditingController _contact;
  late final TextEditingController _mobile;
  late final TextEditingController _loginPassword;
  late final TextEditingController _loginPasswordConfirm;
  late final TextEditingController _otherType;

  late String _initialBusiness;
  late String _initialTypeId;
  late String _initialOwner;
  late String _initialEmail;
  late String _initialGst;
  late String _initialFssai;
  late String _initialPan;
  late String _initialContact;
  late String _initialOtherType;
  late String _typeId;
  Object? _avatarBounceKey;

  bool _setPasswordExpanded = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordSectionError;
  String? _otherTypeError;
  String? _emailError;
  bool _savingPassword = false;

  final _picker = ImagePicker();
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _isValidEmail(String value) {
    if (value.trim().isEmpty) return true;
    return _emailRegex.hasMatch(value.trim());
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _initialBusiness = user?.businessName ?? '';
    _initialTypeId = user?.businessTypeId ??
        BusinessTypes.byId(user?.businessType).id;
    _initialOwner = user?.ownerName ?? '';
    _initialEmail = user?.email ?? '';
    _initialGst = user?.gstNumber ?? '';
    _initialFssai = user?.fssaiNumber ?? '';
    _initialPan = user?.panNumber ?? '';
    _initialContact = user?.contactPerson ?? '';
    _typeId = _initialTypeId;
    _initialOtherType = BusinessTypes.isOther(_initialTypeId)
        ? (user?.businessType ?? '')
        : '';
    _business = TextEditingController(text: _initialBusiness);
    _owner = TextEditingController(text: _initialOwner);
    _email = TextEditingController(text: _initialEmail);
    _gst = TextEditingController(text: _initialGst);
    _fssai = TextEditingController(text: _initialFssai);
    _pan = TextEditingController(text: _initialPan);
    _contact = TextEditingController(text: _initialContact);
    _mobile = TextEditingController(text: user?.mobile ?? '');
    _loginPassword = TextEditingController();
    _loginPasswordConfirm = TextEditingController();
    _otherType = TextEditingController(text: _initialOtherType);
    _setPasswordExpanded = user?.hasPassword != true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _business.dispose();
    _owner.dispose();
    _email.dispose();
    _gst.dispose();
    _fssai.dispose();
    _pan.dispose();
    _contact.dispose();
    _mobile.dispose();
    _loginPassword.dispose();
    _loginPasswordConfirm.dispose();
    _otherType.dispose();
    super.dispose();
  }

  bool get _dirty {
    return _business.text.trim() != _initialBusiness ||
        _typeId != _initialTypeId ||
        _owner.text.trim() != _initialOwner ||
        _email.text.trim() != _initialEmail ||
        _gst.text.trim() != _initialGst ||
        _fssai.text.trim() != _initialFssai ||
        _pan.text.trim() != _initialPan ||
        _contact.text.trim() != _initialContact ||
        (BusinessTypes.isOther(_typeId) &&
            _otherType.text.trim() != _initialOtherType);
  }

  Future<void> _save() async {
    if (BusinessTypes.isOther(_typeId) && _otherType.text.trim().isEmpty) {
      setState(() => _otherTypeError = 'Please describe your business type');
      return;
    }
    if (!_isValidEmail(_email.text)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }
    if (_owner.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner name is required'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final auth = context.read<AuthViewModel>();
    final ok = await auth.updateProfile(
      businessName: _business.text,
      businessType: _typeId,
      businessTypeOther: _otherType.text,
      ownerName: _owner.text,
      email: _email.text,
      gstNumber: _gst.text,
      fssaiNumber: _fssai.text,
      panNumber: _pan.text,
      contactPerson: _contact.text,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not save profile'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }
    showAppSuccessSnackBar(context, message: 'Profile updated successfully');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveLoginPassword() async {
    final email = _email.text.trim();
    final password = _loginPassword.text;
    final confirm = _loginPasswordConfirm.text;
    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      setState(
        () => _passwordSectionError =
            email.isEmpty
                ? 'Add your email in the form above first'
                : 'Enter a valid email address in the Email field above',
      );
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordSectionError = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _passwordSectionError = 'Passwords do not match');
      return;
    }
    setState(() {
      _passwordSectionError = null;
      _savingPassword = true;
    });
    final auth = context.read<AuthViewModel>();
    // Persist email on profile if it changed, then set password.
    if (email != (auth.user?.email ?? '')) {
      await auth.updateProfile(
        businessName: _business.text.trim().isEmpty
            ? (auth.user?.businessName ?? '')
            : _business.text,
        businessType: _typeId,
        businessTypeOther: _otherType.text,
        ownerName: _owner.text,
        email: email,
        gstNumber: _gst.text,
        fssaiNumber: _fssai.text,
        panNumber: _pan.text,
        contactPerson: _contact.text,
      );
    }
    final ok = await auth.setLoginPassword(email: email, password: password);
    if (!mounted) return;
    setState(() => _savingPassword = false);
    if (!ok) {
      setState(() => _passwordSectionError = auth.error ?? 'Could not set password');
      return;
    }
    _loginPassword.clear();
    _loginPasswordConfirm.clear();
    setState(() {
      _setPasswordExpanded = false;
      _initialEmail = email;
    });
    showAppSuccessSnackBar(
      context,
      message: 'Password set — you can now login with email',
    );
  }

  Future<void> _uploadDocument(RegistrationDocumentType type) async {
    final path = await pickRegistrationDocument(context, type);
    if (path == null || !mounted) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.saveDocument(type, path);
    if (!mounted) return;
    if (ok) {
      showAppSuccessSnackBar(context, message: '${type.label} uploaded');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Upload failed'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  void _scrollToDocuments() {
    final ctx = _documentsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: AppMotion.normal,
      curve: AppMotion.ease,
      alignment: 0.1,
    );
  }

  Future<void> _openAvatarSheet() async {
    final auth = context.read<AuthViewModel>();
    final hasPhoto =
        auth.user?.avatarPath != null && auth.user!.avatarPath!.isNotEmpty;
    await showAvatarSourceSheet(
      context,
      hasPhoto: hasPhoto,
      onCamera: () => _pickAndUpload(ImageSource.camera),
      onGallery: () => _pickAndUpload(ImageSource.gallery),
      onRemove: hasPhoto
          ? () async {
              final ok = await auth.removeAvatar();
              if (!mounted) return;
              if (ok) {
                setState(() => _avatarBounceKey = DateTime.now());
                showAppSuccessSnackBar(context, message: 'Photo removed');
              }
            }
          : null,
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop photo',
            toolbarColor: AppColors.violet,
            toolbarWidgetColor: AppColors.white,
            activeControlsWidgetColor: AppColors.violet,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop photo',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (cropped == null || !mounted) return;

      final auth = context.read<AuthViewModel>();
      final ok = await auth.uploadAvatar(cropped.path);
      if (!mounted) return;
      if (ok) {
        setState(() => _avatarBounceKey = DateTime.now());
        showAppSuccessSnackBar(context, message: 'Profile photo updated');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Upload failed'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update photo: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    final kyc = auth.user?.kycStatus ?? KycStatus.approved;
    final docs = auth.documents;

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Profile Details', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  'Business profile',
                  style: AppTextStyles.display(fontSize: 22),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 4),
                Text(
                  'Update how buyers see your business on VeggiiCart.',
                  style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                ).animate().fadeIn(delay: 40.ms, duration: 200.ms),
                const SizedBox(height: 20),
                Center(
                  child: ProfileAvatar(
                    user: auth.user,
                    size: 96,
                    showCameraBadge: true,
                    isUploading: auth.isUploadingAvatar,
                    bounceKey: _avatarBounceKey,
                    onCameraTap: _openAvatarSheet,
                  ),
                ).animate().fadeIn(delay: 50.ms, duration: 220.ms).scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      delay: 50.ms,
                    ),
                const SizedBox(height: 16),
                _KycStatusRow(
                  status: kyc,
                  onTap: () => AppPageRoute.push(
                    context,
                    const VerificationStatusScreen(fromProfile: true),
                  ),
                  onDocumentsHint: kyc == KycStatus.rejected ? _scrollToDocuments : null,
                ).animate().fadeIn(delay: 70.ms, duration: 200.ms),
                const SizedBox(height: 24),
                const AuthFieldLabel('Business / Shop Name'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _business,
                  hint: 'e.g. Sharma Restaurant Supplies',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('Owner Name'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _owner,
                  hint: 'Full name of owner',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('Email', optional: true),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _email,
                  hint: 'orders@yourshop.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) => setState(() => _emailError = null),
                ),
                const SizedBox(height: 18),
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
                    final selected = t.id == _typeId;
                    return PressableScale(
                      onTap: () => setState(() {
                        _typeId = t.id;
                        if (!BusinessTypes.isOther(t.id)) {
                          _otherTypeError = null;
                        }
                      }),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.violet : AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: selected ? AppColors.violet : AppColors.line,
                          ),
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
                if (BusinessTypes.isOther(_typeId)) ...[
                  const SizedBox(height: 14),
                  const AuthFieldLabel('Specify business type'),
                  const SizedBox(height: 8),
                  PillTextField(
                    controller: _otherType,
                    hint: 'e.g. Cloud kitchen, Bakery wholesale…',
                    textCapitalization: TextCapitalization.words,
                    errorText: _otherTypeError,
                    onChanged: (_) => setState(() => _otherTypeError = null),
                  ),
                ],
                const SizedBox(height: 18),
                const AuthFieldLabel('GSTIN', optional: true),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _gst,
                  hint: '22AAAAA0000A1Z5',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('FSSAI License Number', optional: true),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _fssai,
                  hint: '12345678901234',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('PAN Number', optional: true),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _pan,
                  hint: 'ABCDE1234F',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('Contact Person Name', optional: true),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _contact,
                  hint: 'Manager / ordering contact',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const AuthFieldLabel('Mobile number'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _mobile,
                  enabled: false,
                  readOnly: true,
                  prefix: const CountryCodeChip(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Contact support to change',
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                KeyedSubtree(
                  key: _documentsKey,
                  child: _DocumentsSection(
                    documents: docs,
                    onUpload: _uploadDocument,
                  ),
                ),
                const SizedBox(height: 20),
                _PasswordOptInSection(
                  hasPassword: auth.user?.hasPassword == true,
                  emailOnFile: _email.text.trim(),
                  expanded: _setPasswordExpanded,
                  onToggleExpand: () =>
                      setState(() => _setPasswordExpanded = !_setPasswordExpanded),
                  passwordController: _loginPassword,
                  confirmController: _loginPasswordConfirm,
                  obscurePassword: _obscurePassword,
                  obscureConfirm: _obscureConfirm,
                  onToggleObscurePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleObscureConfirm: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  errorText: _passwordSectionError,
                  isSaving: _savingPassword || auth.isLoading,
                  onSave: _saveLoginPassword,
                  onFieldChanged: () {
                    if (_passwordSectionError != null) {
                      setState(() => _passwordSectionError = null);
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.95),
              boxShadow: AppShadows.soft(opacity: 0.06),
            ),
            child: AuthPrimaryButton(
              label: 'Save Changes',
              isLoading: auth.isLoading && !_savingPassword,
              enabled: _dirty &&
                  _business.text.trim().isNotEmpty &&
                  _owner.text.trim().isNotEmpty &&
                  (!BusinessTypes.isOther(_typeId) ||
                      _otherType.text.trim().isNotEmpty),
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycStatusRow extends StatelessWidget {
  const _KycStatusRow({
    required this.status,
    required this.onTap,
    this.onDocumentsHint,
  });

  final KycStatus status;
  final VoidCallback onTap;
  final VoidCallback? onDocumentsHint;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (status) {
      case KycStatus.pending:
        bg = const Color(0xFFFFF4D6);
        fg = const Color(0xFFB8860B);
      case KycStatus.approved:
        bg = AppColors.greenSoft;
        fg = AppColors.green;
      case KycStatus.rejected:
        bg = AppColors.alert.withValues(alpha: 0.12);
        fg = AppColors.alert;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PressableScale(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Text(
                  'Verification',
                  style: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    status.label,
                    style: AppTextStyles.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
              ],
            ),
          ),
        ),
        if (onDocumentsHint != null) ...[
          const SizedBox(height: 8),
          PressableScale(
            onTap: onDocumentsHint,
            child: Text(
              'Documents need attention →',
              style: AppTextStyles.body(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.alert,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.documents,
    required this.onUpload,
  });

  final Map<String, String> documents;
  final ValueChanged<RegistrationDocumentType> onUpload;

  @override
  Widget build(BuildContext context) {
    // Show all 9 types on Profile (parity with Registration catalogue).
    const types = RegistrationDocumentType.values;
    final uploadedCount = types.where((t) => documents.containsKey(t.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOCUMENTS',
          style: AppTextStyles.label(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$uploadedCount of ${types.length} uploaded — tap to add or replace',
          style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        ...types.map((type) {
          final path = documents[type.id];
          final uploaded = path != null;
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
                    color: uploaded ? AppColors.success : AppColors.line,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: uploaded
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.section,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        uploaded
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        color: uploaded ? AppColors.success : AppColors.violet,
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
                                    color: AppColors.alert,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            uploaded ? 'Uploaded' : 'Not uploaded',
                            style: AppTextStyles.body(
                              fontSize: 12,
                              color: uploaded ? AppColors.success : AppColors.muted,
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

class _PasswordOptInSection extends StatelessWidget {
  const _PasswordOptInSection({
    required this.hasPassword,
    required this.emailOnFile,
    required this.expanded,
    required this.onToggleExpand,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirm,
    required this.errorText,
    required this.isSaving,
    required this.onSave,
    required this.onFieldChanged,
  });

  final bool hasPassword;
  final String emailOnFile;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirm;
  final String? errorText;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressableScale(
            onTap: onToggleExpand,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasPassword
                            ? 'Email & password login'
                            : 'Set a password for faster login',
                        style: AppTextStyles.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasPassword
                            ? 'Uses the email above. Tap to update password.'
                            : 'Uses the Email field above — set a password to enable email login.',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          color: AppColors.muted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
          if (hasPassword && !expanded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                'Enabled',
                style: AppTextStyles.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
          if (expanded) ...[
            const SizedBox(height: 12),
            Text(
              emailOnFile.isEmpty
                  ? 'Fill in Email above first'
                  : 'Password for $emailOnFile',
              style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            const AuthFieldLabel('Password'),
            const SizedBox(height: 8),
            PillTextField(
              controller: passwordController,
              hint: 'Min. 6 characters',
              obscureText: obscurePassword,
              suffix: IconButton(
                onPressed: onToggleObscurePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                  size: 22,
                ),
              ),
              onChanged: (_) => onFieldChanged(),
            ),
            const SizedBox(height: 14),
            const AuthFieldLabel('Confirm password'),
            const SizedBox(height: 8),
            PillTextField(
              controller: confirmController,
              hint: 'Re-enter password',
              obscureText: obscureConfirm,
              suffix: IconButton(
                onPressed: onToggleObscureConfirm,
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                  size: 22,
                ),
              ),
              onChanged: (_) => onFieldChanged(),
            ),
            if (errorText != null && errorText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: AppTextStyles.body(fontSize: 12, color: AppColors.alert),
              ),
            ],
            const SizedBox(height: 14),
            AuthPrimaryButton(
              label: hasPassword ? 'Update Password' : 'Enable Email Login',
              isLoading: isSaving,
              onPressed: onSave,
            ),
          ],
        ],
      ),
    );
  }
}
