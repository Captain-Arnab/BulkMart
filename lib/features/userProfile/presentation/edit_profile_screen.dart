import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/userProfile/domain/UserProfileController.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _controller = Get.put(UserProfileController());
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  ApiViewStatus _status = ApiViewStatus.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = ApiViewStatus.loading);
    try {
      final data = await _controller.fetchUserData();
      _fname.text = data['cust_fname']?.toString() ?? data['name']?.toString() ?? '';
      _lname.text = data['cust_lname']?.toString() ?? '';
      _email.text = data['cust_email']?.toString() ?? data['email']?.toString() ?? '';
      _mobile.text = data['cust_mobile']?.toString() ?? data['phone']?.toString() ?? '';
      _address.text = data['address']?.toString() ?? '';
      _city.text = data['city']?.toString() ?? '';
      _state.text = data['state']?.toString() ?? '';
      setState(() => _status = ApiViewStatus.success);
    } catch (e) {
      setState(() {
        _status = ApiViewStatus.error;
        _error = e.toString();
      });
    }
  }

  Future<void> _save() async {
    setState(() => _status = ApiViewStatus.loading);
    final result = await _controller.updateProfile(
      custFname: _fname.text,
      custLname: _lname.text,
      custEmail: _email.text,
      custMobile: _mobile.text,
      address: _address.text,
      city: _city.text,
      state: _state.text,
    );
    if (!mounted) return;
    if (result is ApiFailure) {
      setState(() {
        _status = ApiViewStatus.error;
        _error = (result as ApiFailure).message;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile', style: GoogleFonts.rubik(fontWeight: FontWeight.w600))),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(controller: _fname, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: _lname, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'Mobile')),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'State')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
