import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/data/network/vendor_api_diagnostics.dart';

/// Copies the last vendor API request/response details to the clipboard.
class VendorApiDebugCopyButton extends StatelessWidget {
  const VendorApiDebugCopyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final text = VendorApiDiagnostics.instance.formatForSharing();
        await Clipboard.setData(ClipboardData(text: text));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'API debug info copied — paste into email/chat for backend team',
              style: GoogleFonts.rubik(fontSize: 13),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      icon: const Icon(Icons.copy_rounded, size: 18),
      label: Text(
        'Copy API debug info',
        style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
      ),
    );
  }
}
