import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_earnings_controller.dart';

class VendorEarningsScreen extends StatelessWidget {
  const VendorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorEarningsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Earnings', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.earnings.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                      Text('Total Earnings', style: GoogleFonts.rubik(fontSize: 14)),
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
              Text('Payout History', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (data == null || data.payouts.isEmpty)
                const Text('No payouts yet')
              else
                ...data.payouts.map(
                  (p) => Card(
                    child: ListTile(title: Text(p)),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
