import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/userProfile/user_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _controller = Get.put(UserProfileController());
  final _formKey = GlobalKey<FormState>();

  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();

  ApiViewStatus _status = ApiViewStatus.loading;
  String? _error;
  bool _saving = false;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _email.dispose();
    _mobile.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _status = ApiViewStatus.loading);
    try {
      final data = await _controller.fetchUserData();
      _fname.text = data['cust_fname']?.toString() ?? '';
      _lname.text = data['cust_lname']?.toString() ?? '';
      _email.text = data['cust_email']?.toString() ?? '';
      _mobile.text = data['cust_mobile']?.toString() ?? '';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
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

    setState(() => _saving = false);

    if (result is ApiFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as ApiFailure).message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.rubik(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryGreen, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.rubik(fontSize: 15),
        decoration: _decoration(label: label, icon: icon),
        validator: validator,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _load,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: lightGreen,
                      child: Icon(Icons.person, size: 44, color: primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Personal info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Personal Information'),
                      _field(
                        controller: _fname,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                      ),
                      _field(
                        controller: _lname,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                      ),
                      _field(
                        controller: _email,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          if (!RegExp(r'^[\w.\-]+@[\w\-]+\.[\w\-.]+$').hasMatch(v)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      _field(
                        controller: _mobile,
                        label: 'Mobile',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Mobile number is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Address info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Address'),
                      _field(
                        controller: _address,
                        label: 'Address',
                        icon: Icons.home_outlined,
                      ),
                      _field(
                        controller: _city,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                      ),
                      _field(
                        controller: _state,
                        label: 'State',
                        icon: Icons.map_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}