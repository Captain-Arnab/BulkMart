import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_earnings_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/payments/vendor_payment_history_screen.dart';
import 'package:urban_roots/features/vendor/support/vendor_support_screen.dart';

class VendorEarningsScreen extends StatelessWidget {
  const VendorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorEarningsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Earnings',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.earnings.value == null) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.errorMessage.value.isNotEmpty && c.earnings.value == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.errorMessage.value),
                ElevatedButton(onPressed: c.load, child: const Text('Retry')),
              ],
            ),
          );
        }
        final data = c.earnings.value;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Earnings',
                          style: GoogleFonts.rubik(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${data?.earnings ?? '0'}',
                        style: GoogleFonts.rubik(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VendorPaymentHistoryScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('View History'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VendorSupportScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.support_agent_rounded, size: 18),
                      label: const Text('Support'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Payout History',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (data == null || data.payouts.isEmpty)
                _buildEmptyPayouts()
              else
                ...data.payouts.map(_buildPayoutTile),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyPayouts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.hint),
          const SizedBox(height: 10),
          Text(
            'No payout history available yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutTile(VendorPayout p) {
    final isPaid = p.status.toLowerCase().contains('paid') ||
        p.status.toLowerCase().contains('complete');
    final statusColor = isPaid ? AppColors.primary : AppColors.hint;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMint,
          child: Icon(Icons.payments_outlined,
              color: AppColors.primaryDark, size: 20),
        ),
        title: Text(
          '₹${p.amount}',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (p.date.isNotEmpty) p.date,
            if (p.payoutId.isNotEmpty) 'ID: ${p.payoutId}',
          ].join(' · '),
          style: GoogleFonts.rubik(fontSize: 12),
        ),
        trailing: p.status.isEmpty
            ? null
            : Text(
                p.status,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
      ),
    );
  }
}
