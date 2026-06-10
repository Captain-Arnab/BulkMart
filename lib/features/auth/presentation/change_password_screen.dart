import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();
  ApiViewStatus _status = ApiViewStatus.idle;

  Future<void> _submit() async {
    if (_newPass.text != _confirm.text) {
      await SweetAlert.warning(context, message: 'Passwords do not match');
      return;
    }
    setState(() => _status = ApiViewStatus.loading);
    final result = await UrbanRootsApi.instance.auth.changePassword(
      currentPassword: _current.text,
      newPassword: _newPass.text,
      confirmPassword: _confirm.text,
    );
    if (!mounted) return;
    if (result is ApiFailure) {
      setState(() => _status = ApiViewStatus.idle);
      await SweetAlert.error(context, message: (result as ApiFailure).message);
      return;
    }
    await SweetAlert.success(
      context,
      message: 'Password changed successfully',
      onConfirm: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
      ),
      body: ApiStateView(
        status: _status,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _current, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
              const SizedBox(height: 12),
              TextField(controller: _newPass, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
              const SizedBox(height: 12),
              TextField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, child: const Text('Submit')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
