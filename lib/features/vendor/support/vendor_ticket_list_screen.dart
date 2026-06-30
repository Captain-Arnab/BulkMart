import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_support_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/support/vendor_raise_ticket_screen.dart';

class VendorTicketListScreen extends StatefulWidget {
  const VendorTicketListScreen({super.key});

  @override
  State<VendorTicketListScreen> createState() => _VendorTicketListScreenState();
}

class _VendorTicketListScreenState extends State<VendorTicketListScreen> {
  late final VendorSupportController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(VendorSupportController());
    c.loadTickets();
  }

  @override
  void dispose() {
    Get.delete<VendorSupportController>();
    super.dispose();
  }

  Future<void> _openRaiseTicket() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VendorRaiseTicketScreen()),
    );
    if (created == true) c.loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Support Tickets',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openRaiseTicket,
        icon: const Icon(Icons.add),
        label: const Text('Raise Ticket'),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.tickets.isEmpty) {
          return const LoadingView(label: 'Loading tickets...');
        }
        if (c.errorMessage.value.isNotEmpty && c.tickets.isEmpty) {
          return FailureView(
            message: c.errorMessage.value,
            onRetry: c.loadTickets,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.loadTickets,
          child: c.tickets.isEmpty
              ? const EmptyView(
                  icon: Icons.confirmation_number_outlined,
                  message: 'No tickets yet',
                  subtitle: 'Raise a ticket and it will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                  itemCount: c.tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _TicketCard(ticket: c.tickets[i]),
                ),
        );
      }),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: const RoundedRectangleBorder(),
          title: Text(
            ticket.subject.isEmpty ? '(No subject)' : ticket.subject,
            style: GoogleFonts.rubik(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                StatusBadge.forStatus(ticket.status),
                const Spacer(),
                if (ticket.createdAt.isNotEmpty)
                  Text(
                    ticket.createdAt,
                    style:
                        GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                  ),
              ],
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ticket.message.isEmpty ? 'No message provided.' : ticket.message,
                style: GoogleFonts.rubik(fontSize: 13, color: Colors.black87),
              ),
            ),
            if (ticket.ticketId.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ticket #${ticket.ticketId}',
                  style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
