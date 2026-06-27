import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_payment_history_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorPaymentHistoryScreen extends StatefulWidget {
  const VendorPaymentHistoryScreen({super.key});

  @override
  State<VendorPaymentHistoryScreen> createState() =>
      _VendorPaymentHistoryScreenState();
}

class _VendorPaymentHistoryScreenState
    extends State<VendorPaymentHistoryScreen> {
  late final VendorPaymentHistoryController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(VendorPaymentHistoryController());
  }

  @override
  void dispose() {
    Get.delete<VendorPaymentHistoryController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Payment History',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.payouts.isEmpty) {
          return const LoadingView(label: 'Loading payouts...');
        }
        if (c.errorMessage.value.isNotEmpty && c.payouts.isEmpty) {
          return FailureView(message: c.errorMessage.value, onRetry: c.load);
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: c.payouts.isEmpty
              ? const EmptyView(
                  icon: Icons.receipt_long_outlined,
                  message: 'No payment history yet',
                  subtitle: 'Your payouts will appear here once processed.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: c.payouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _PayoutCard(item: c.payouts[i]),
                ),
        );
      }),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.item});

  final PayoutHistoryItem item;

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
                  'Payout #${item.payoutId}',
                  style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              StatusBadge.forStatus(item.status),
            ],
          ),
          if (item.date.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.date,
              style: GoogleFonts.rubik(fontSize: 12, color: AppColors.hint),
            ),
          ],
          const Divider(height: 20),
          _row('Gross Amount', '₹${item.amount}'),
          const SizedBox(height: 6),
          _row('Commission Deducted', '- ₹${item.commissionDeducted}'),
          const SizedBox(height: 6),
          _row('Net Amount', '₹${item.netAmount}', highlight: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint)),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: highlight ? 15 : 13,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
