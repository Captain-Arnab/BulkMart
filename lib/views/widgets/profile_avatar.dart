import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'remote_network_image.dart';

/// Circular profile avatar — initials / local photo / remote URL / loading ring.
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

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _lastBounceKey = widget.bounceKey;
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bounceKey != null && widget.bounceKey != _lastBounceKey) {
      _lastBounceKey = widget.bounceKey;
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.user?.avatarPath?.trim();
    final networkUrl = _networkAvatarUrl(raw);
    final localPath = _localAvatarPath(raw);

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
              child: _buildFace(
                networkUrl: networkUrl,
                localPath: localPath,
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

  Widget _buildFace({required String? networkUrl, required String? localPath}) {
    final initials = Center(
      child: Text(
        widget.user?.initials ?? 'B',
        style: AppTextStyles.display(
          fontSize: widget.size * 0.32,
          color: AppColors.violet,
        ),
      ),
    );

    if (networkUrl != null) {
      final cache = (widget.size * MediaQuery.devicePixelRatioOf(context))
          .round()
          .clamp(48, 512);
      return RemoteNetworkImage(
        imageUrl: networkUrl,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        memCacheWidth: cache,
        memCacheHeight: cache,
        placeholder: initials,
        errorWidget: initials,
      );
    }

    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (_, __, ___) => initials,
      );
    }

    return initials;
  }

  /// Remote `avatar_url` from API (absolute or site-relative).
  static String? _networkAvatarUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return raw;
    }
    // Site-relative upload path, e.g. `/public/uploads/avatars/...`
    if (raw.startsWith('/')) {
      final api = Uri.parse(AppConfig.apiBaseUrl);
      return Uri(
        scheme: api.scheme,
        host: api.host,
        port: api.hasPort ? api.port : null,
        path: raw,
      ).toString();
    }
    return null;
  }

  /// Local cropped file still on disk (pre-upload / offline preview).
  static String? _localAvatarPath(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (_networkAvatarUrl(raw) != null) return null;
    try {
      if (File(raw).existsSync()) return raw;
    } catch (_) {}
    return null;
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
