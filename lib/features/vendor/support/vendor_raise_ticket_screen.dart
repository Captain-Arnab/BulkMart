import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_support_controller.dart';

/// Raise / contact-support form. Pass [payoutId] when navigating from a payout
/// detail to pre-link the ticket to that payout (the field is only shown then).
class VendorRaiseTicketScreen extends StatefulWidget {
  const VendorRaiseTicketScreen({super.key, this.payoutId});

  final String? payoutId;

  @override
  State<VendorRaiseTicketScreen> createState() =>
      _VendorRaiseTicketScreenState();
}

class _VendorRaiseTicketScreenState extends State<VendorRaiseTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  late final VendorSupportController c;

  bool get _hasPayout =>
      widget.payoutId != null && widget.payoutId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Reuse the existing controller if the ticket list already created it,
    // otherwise create a standalone instance for this screen.
    c = Get.isRegistered<VendorSupportController>()
        ? Get.find<VendorSupportController>()
        : Get.put(VendorSupportController());
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await c.raiseTicket(
      subject: _subject.text.trim(),
      message: _message.text.trim(),
      payoutId: _hasPayout ? widget.payoutId : null,
    );
    if (!mounted) return;
    if (result.error == null) {
      final id = result.ticketId;
      Get.snackbar(
        'Ticket raised',
        id != null && id.isNotEmpty
            ? 'Your ticket #$id has been submitted.'
            : 'Your ticket has been submitted.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.pop(context, true);
    } else {
      Get.snackbar(
        'Could not submit',
        result.error!,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Raise Ticket',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasPayout) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Linked to payout #${widget.payoutId}',
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _label('Subject'),
              TextFormField(
                controller: _subject,
                decoration: _dec('Brief summary of the issue'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _label('Message'),
              TextFormField(
                controller: _message,
                maxLines: 6,
                decoration: _dec('Describe your issue in detail'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: c.isSubmitting.value ? null : _submit,
                    child: c.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Ticket'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
