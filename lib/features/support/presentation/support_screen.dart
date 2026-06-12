import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _orderId = TextEditingController();
  ApiViewStatus _status = ApiViewStatus.idle;
  bool _submitting = false;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _orderId.dispose();
    super.dispose();
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _status = ApiViewStatus.loading;
      _submitting = true;
    });

    final result = await UrbanRootsApi.instance.support.createTicket(
      subject: _subject.text.trim(),
      message: _message.text.trim(),
      orderId: _orderId.text.trim().isEmpty ? null : _orderId.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _status = ApiViewStatus.idle;
      _submitting = false;
    });

    if (result is ApiFailure) {
      final failure = result as ApiFailure;
      showApiSnackBar(context, failure.message, isError: true);
      return;
    }

    final ticketId = (result as ApiSuccess).data['ticket_id'];
    showApiSnackBar(context, 'Ticket #$ticketId created');
    Navigator.pop(context, true);
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
          'Help & Support',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ApiStateView(
        status: _status,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      child: Icon(Icons.support_agent_outlined,
                          size: 44, color: primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                      _sectionTitle('Support Request'),
                      _field(
                        controller: _subject,
                        label: 'Subject',
                        icon: Icons.subject_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject is required';
                          }
                          return null;
                        },
                      ),
                      _field(
                        controller: _orderId,
                        label: 'Order ID (optional)',
                        icon: Icons.confirmation_number_outlined,
                      ),
                      _field(
                        controller: _message,
                        label: 'Message',
                        icon: Icons.message_outlined,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Message is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit Request',
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
