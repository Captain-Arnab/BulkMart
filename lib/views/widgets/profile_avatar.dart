import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Circular profile avatar — initials / photo / loading ring.
class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.user,
    this.size = 96,
    this.showCameraBadge = false,
    this.onCameraTap,
    this.isUploading = false,
    this.bounceKey,
  });

  final User? user;
  final double size;
  final bool showCameraBadge;
  final VoidCallback? onCameraTap;
  final bool isUploading;

  /// Change this after a successful upload to trigger scale bounce.
  final Object? bounceKey;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  Object? _lastBounceKey;

  String? _resolvedPath;
  bool _hasFile = false;

  void _resolveAvatarFile() {
    final path = widget.user?.avatarPath;
    if (path == null || path.isEmpty) {
      _resolvedPath = null;
      _hasFile = false;
      return;
    }
    if (path == _resolvedPath) return;
    _resolvedPath = path;
    _hasFile = File(path).existsSync();
  }

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _lastBounceKey = widget.bounceKey;
    _resolveAvatarFile();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bounceKey != null && widget.bounceKey != _lastBounceKey) {
      _lastBounceKey = widget.bounceKey;
      _bounce.forward(from: 0);
    }
    if (oldWidget.user?.avatarPath != widget.user?.avatarPath) {
      _resolveAvatarFile();
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _resolvedPath;
    final hasFile = _hasFile;

    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        final scale = 1.0 + 0.08 * math.sin(_bounce.value * math.pi);
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasFile && path != null
                  ? Image.file(File(path), fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        widget.user?.initials ?? 'B',
                        style: AppTextStyles.display(
                          fontSize: widget.size * 0.32,
                          color: AppColors.violet,
                        ),
                      ),
                    ),
            ),
            if (widget.isUploading)
              Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.violet,
                  backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                ),
              ),
            if (widget.showCameraBadge)
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: AppColors.ink.withValues(alpha: 0.2),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onCameraTap,
                    child: SizedBox(
                      width: widget.size * 0.34,
                      height: widget.size * 0.34,
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.violet,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAvatarSourceSheet(
  BuildContext context, {
  required bool hasPhoto,
  required VoidCallback onCamera,
  required VoidCallback onGallery,
  VoidCallback? onRemove,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
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
            Text('Profile photo', style: AppTextStyles.display(fontSize: 18)),
            const SizedBox(height: 12),
            _sheetTile(
              icon: Icons.photo_camera_rounded,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(ctx);
                onCamera();
              },
            ),
            _sheetTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(ctx);
                onGallery();
              },
            ),
            if (hasPhoto && onRemove != null)
              _sheetTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: AppColors.alert,
                onTap: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
              ),
          ],
        ),
      );
    },
  );
}

Widget _sheetTile({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color color = AppColors.ink,
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      label,
      style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600, color: color),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}
