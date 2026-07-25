import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Account',
          style: AppTextStyles.display(fontSize: 18, color: AppColors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.businessName ?? 'Business',
                  style: AppTextStyles.display(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _row('Mobile', user != null ? '+91 ${user.mobile}' : '—'),
                _row('Address', user?.address ?? 'Not set'),
                _row('GST', user?.gstNumber ?? 'Not provided'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Saved addresses', style: AppTextStyles.display(fontSize: 15)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              user?.address ?? 'No saved addresses yet.',
              style: AppTextStyles.body(color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Logout',
            backgroundColor: AppColors.ink,
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTextStyles.label(fontSize: 10)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
