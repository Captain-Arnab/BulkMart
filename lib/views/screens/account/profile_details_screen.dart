import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/business_type.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/profile_avatar.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late final TextEditingController _business;
  late final TextEditingController _gst;
  late final TextEditingController _contact;
  late final TextEditingController _mobile;
  late final TextEditingController _loginEmail;
  late final TextEditingController _loginPassword;
  late final TextEditingController _loginPasswordConfirm;

  late String _initialBusiness;
  late String _initialTypeId;
  late String _initialGst;
  late String _initialContact;
  late String _typeId;
  Object? _avatarBounceKey;

  bool _setPasswordExpanded = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordSectionError;
  bool _savingPassword = false;

  final _picker = ImagePicker();
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _initialBusiness = user?.businessName ?? '';
    _initialTypeId = user?.businessTypeId ??
        BusinessTypes.byId(user?.businessType).id;
    _initialGst = user?.gstNumber ?? '';
    _initialContact = user?.displayOwnerName ?? '';
    _typeId = _initialTypeId;
    _business = TextEditingController(text: _initialBusiness);
    _gst = TextEditingController(text: _initialGst);
    _contact = TextEditingController(text: _initialContact);
    _mobile = TextEditingController(text: user?.mobile ?? '');
    _loginEmail = TextEditingController(text: user?.email ?? '');
    _loginPassword = TextEditingController();
    _loginPasswordConfirm = TextEditingController();
    _setPasswordExpanded = user?.hasPassword != true;
  }

  @override
  void dispose() {
    _business.dispose();
    _gst.dispose();
    _contact.dispose();
    _mobile.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _loginPasswordConfirm.dispose();
    super.dispose();
  }

  bool get _dirty {
    return _business.text.trim() != _initialBusiness ||
        _typeId != _initialTypeId ||
        _gst.text.trim() != _initialGst ||
        _contact.text.trim() != _initialContact;
  }

  Future<void> _save() async {
    final auth = context.read<AuthViewModel>();
    final ok = await auth.updateProfile(
      businessName: _business.text,
      businessType: _typeId,
      gstNumber: _gst.text,
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
    final email = _loginEmail.text.trim();
    final password = _loginPassword.text;
    final confirm = _loginPasswordConfirm.text;
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _passwordSectionError = 'Enter a valid email address');
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
    final ok = await auth.setLoginPassword(email: email, password: password);
    if (!mounted) return;
    setState(() => _savingPassword = false);
    if (!ok) {
      setState(() => _passwordSectionError = auth.error ?? 'Could not set password');
      return;
    }
    _loginPassword.clear();
    _loginPasswordConfirm.clear();
    setState(() => _setPasswordExpanded = false);
    showAppSuccessSnackBar(
      context,
      message: 'Password set — you can now login with email',
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  'Business profile',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
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
                const SizedBox(height: 24),
                const AuthFieldLabel('Business / Shop Name'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _business,
                  hint: 'e.g. Sharma Restaurant Supplies',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ).animate().fadeIn(delay: 60.ms, duration: 200.ms).slideY(begin: 0.1, end: 0),
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
                      onTap: () => setState(() => _typeId = t.id),
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
                ).animate().fadeIn(delay: 100.ms, duration: 200.ms),
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
                ).animate().fadeIn(delay: 140.ms, duration: 200.ms),
                const SizedBox(height: 18),
                const AuthFieldLabel('Contact Person Name'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _contact,
                  hint: 'Owner / manager name',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ).animate().fadeIn(delay: 180.ms, duration: 200.ms),
                const SizedBox(height: 18),
                const AuthFieldLabel('Mobile number'),
                const SizedBox(height: 8),
                PillTextField(
                  controller: _mobile,
                  enabled: false,
                  readOnly: true,
                  prefix: const CountryCodeChip(),
                ).animate().fadeIn(delay: 220.ms, duration: 200.ms),
                const SizedBox(height: 6),
                Text(
                  'Contact support to change',
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                _PasswordOptInSection(
                  hasPassword: auth.user?.hasPassword == true,
                  expanded: _setPasswordExpanded,
                  onToggleExpand: () =>
                      setState(() => _setPasswordExpanded = !_setPasswordExpanded),
                  emailController: _loginEmail,
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
                ).animate().fadeIn(delay: 240.ms, duration: 200.ms),
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
              isLoading: auth.isLoading,
              enabled: _dirty && _business.text.trim().isNotEmpty,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordOptInSection extends StatelessWidget {
  const _PasswordOptInSection({
    required this.hasPassword,
    required this.expanded,
    required this.onToggleExpand,
    required this.emailController,
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
  final bool expanded;
  final VoidCallback onToggleExpand;
  final TextEditingController emailController;
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
                            ? 'You can sign in with email on the Login screen. Tap to update.'
                            : 'Optional — after mobile registration, opt into email + password.',
                        style: AppTextStyles.body(fontSize: 12, color: AppColors.muted, height: 1.35),
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
            const SizedBox(height: 16),
            const AuthFieldLabel('Login email'),
            const SizedBox(height: 8),
            PillTextField(
              controller: emailController,
              hint: 'you@business.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => onFieldChanged(),
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
