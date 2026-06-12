import 'package:flutter/material.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/notifications/push_notification_service.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/profile/vendor_profile_view_model.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  late final VendorProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = VendorProfileViewModel();
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout?', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        content: Text('You will need to sign in again.', style: GoogleFonts.rubik()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: GoogleFonts.rubik(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await PushNotificationService.instance.unregisterFromBackend();
      await AuthSession.instance.clear();
      if (!mounted) return;
      await showLogoutSuccessAndNavigate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = _vm.state;
    if (state is UiLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is UiError<VendorProfile>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(onPressed: _vm.load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final p = (state as UiSuccess<VendorProfile>).data;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _infoRow(Icons.email_outlined, p.email),
                _infoRow(Icons.phone_outlined, p.phone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business Info', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _infoRow(Icons.receipt_outlined, 'GST: ${p.gstNo}'),
                _infoRow(Icons.badge_outlined, 'PAN: ${p.panNo}'),
                _infoRow(Icons.verified_outlined, 'FSSAI: ${p.fssai}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              SweetAlert.info(context, message: 'Edit profile form — wire when API is ready');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF019934),
              side: const BorderSide(color: Color(0xFF019934)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Edit Profile', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Logout', style: GoogleFonts.rubik(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade800))),
        ],
      ),
    );
  }
}
