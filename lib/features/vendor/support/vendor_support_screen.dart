import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_support_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorSupportScreen extends StatefulWidget {
  const VendorSupportScreen({super.key});

  @override
  State<VendorSupportScreen> createState() => _VendorSupportScreenState();
}

class _VendorSupportScreenState extends State<VendorSupportScreen>
    with SingleTickerProviderStateMixin {
  late final VendorSupportController c;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    c = Get.put(VendorSupportController());
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    Get.delete<VendorSupportController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Support',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.hint,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.rubik(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'My Tickets'),
            Tab(text: 'Raise Ticket'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MyTicketsTab(controller: c),
          _RaiseTicketTab(
            controller: c,
            onSubmitted: () => _tabs.animateTo(0),
          ),
        ],
      ),
    );
  }
}

class _MyTicketsTab extends StatelessWidget {
  const _MyTicketsTab({required this.controller});

  final VendorSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.tickets.isEmpty) {
        return const LoadingView(label: 'Loading tickets...');
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.tickets.isEmpty) {
        return FailureView(
          message: controller.errorMessage.value,
          onRetry: controller.loadTickets,
        );
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.loadTickets,
        child: controller.tickets.isEmpty
            ? const EmptyView(
                icon: Icons.confirmation_number_outlined,
                message: 'No tickets yet',
                subtitle: 'Raise a ticket and it will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _TicketCard(ticket: controller.tickets[i]),
              ),
      );
    });
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject.isEmpty ? '(No subject)' : ticket.subject,
                  style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              StatusBadge.forStatus(ticket.status),
            ],
          ),
          if (ticket.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              ticket.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(fontSize: 13, color: Colors.black87),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (ticket.ticketId.isNotEmpty)
                Text(
                  '#${ticket.ticketId}',
                  style:
                      GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                ),
              const Spacer(),
              if (ticket.createdAt.isNotEmpty)
                Text(
                  ticket.createdAt,
                  style:
                      GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RaiseTicketTab extends StatefulWidget {
  const _RaiseTicketTab({required this.controller, required this.onSubmitted});

  final VendorSupportController controller;
  final VoidCallback onSubmitted;

  @override
  State<_RaiseTicketTab> createState() => _RaiseTicketTabState();
}

class _RaiseTicketTabState extends State<_RaiseTicketTab> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _payoutId = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _payoutId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await widget.controller.raiseTicket(
      subject: _subject.text.trim(),
      message: _message.text.trim(),
      payoutId: _payoutId.text.trim(),
    );
    if (!mounted) return;
    if (error == null) {
      _subject.clear();
      _message.clear();
      _payoutId.clear();
      Get.snackbar(
        'Ticket raised',
        'Your ticket has been submitted.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      widget.onSubmitted();
    } else {
      Get.snackbar(
        'Could not submit',
        error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Subject'),
            TextFormField(
              controller: _subject,
              decoration: _dec('Brief summary of the issue'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
            ),
            const SizedBox(height: 16),
            _label('Message'),
            TextFormField(
              controller: _message,
              maxLines: 5,
              decoration: _dec('Describe your issue in detail'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Message is required' : null,
            ),
            const SizedBox(height: 16),
            _label('Payout ID (optional)'),
            TextFormField(
              controller: _payoutId,
              keyboardType: TextInputType.number,
              decoration: _dec('Enter payout ID if this is a payment issue'),
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
                  onPressed:
                      widget.controller.isSubmitting.value ? null : _submit,
                  child: widget.controller.isSubmitting.value
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
