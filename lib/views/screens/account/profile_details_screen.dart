import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
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
  static const _types = ['Wholesaler', 'Restaurant', 'Retailer', 'Other'];

  late final TextEditingController _business;
  late final TextEditingController _gst;
  late final TextEditingController _contact;
  late final TextEditingController _mobile;

  late String _initialBusiness;
  late String _initialType;
  late String _initialGst;
  late String _initialContact;
  late String _type;
  Object? _avatarBounceKey;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _initialBusiness = user?.businessName ?? '';
    _initialType = user?.businessType ?? 'Wholesaler';
    _initialGst = user?.gstNumber ?? '';
    _initialContact = user?.contactPerson ?? '';
    _type = _initialType;
    _business = TextEditingController(text: _initialBusiness);
    _gst = TextEditingController(text: _initialGst);
    _contact = TextEditingController(text: _initialContact);
    _mobile = TextEditingController(text: user?.mobile ?? '');
  }

  @override
  void dispose() {
    _business.dispose();
    _gst.dispose();
    _contact.dispose();
    _mobile.dispose();
    super.dispose();
  }

  bool get _dirty {
    return _business.text.trim() != _initialBusiness ||
        _type != _initialType ||
        _gst.text.trim() != _initialGst ||
        _contact.text.trim() != _initialContact;
  }

  Future<void> _save() async {
    final auth = context.read<AuthViewModel>();
    final ok = await auth.updateProfile(
      businessName: _business.text,
      businessType: _type,
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
                  'Update how buyers see your business on BulkMart.',
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
                  children: _types.map((t) {
                    final selected = t == _type;
                    return PressableScale(
                      onTap: () => setState(() => _type = t),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.violet : AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: selected ? AppColors.violet : AppColors.line,
                          ),
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
