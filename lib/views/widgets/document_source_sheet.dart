import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/registration_document.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../core/ui/app_motion.dart';

/// Shared Take Photo / Gallery / PDF sheet used by Registration + Profile.
Future<String?> pickRegistrationDocument(
  BuildContext context,
  RegistrationDocumentType type,
) async {
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
  if (choice == null) return null;

  if (choice == 'pdf') {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return result?.files.single.path;
  }

  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
    imageQuality: 85,
  );
  return file?.path;
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
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.violet),
      title: Text(
        label,
        style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
    );
  }
}
