import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/admin/controllers/admin_payout_report_controller.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';

class AdminVendorPayoutReportScreen extends StatefulWidget {
  const AdminVendorPayoutReportScreen({super.key});

  @override
  State<AdminVendorPayoutReportScreen> createState() =>
      _AdminVendorPayoutReportScreenState();
}

class _AdminVendorPayoutReportScreenState
    extends State<AdminVendorPayoutReportScreen> {
  late final AdminPayoutReportController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(AdminPayoutReportController());
  }

  @override
  void dispose() {
    Get.delete<AdminPayoutReportController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Vendor Payout Report',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: const [
          IconButton(
            tooltip: 'Export (coming soon)',
            onPressed: null,
            icon: Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.report.isEmpty) {
                return const LoadingView(label: 'Loading report...');
              }
              if (c.errorMessage.value.isNotEmpty && c.report.isEmpty) {
                return FailureView(
                    message: c.errorMessage.value, onRetry: c.load);
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: c.load,
                child: c.report.isEmpty
                    ? const EmptyView(
                        icon: Icons.account_balance_outlined,
                        message: 'No payout data',
                        subtitle: 'No vendor payouts for this selection.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: c.report.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _PayoutRow(item: c.report[i]),
                      ),
              );
            }),
          ),
          _buildSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String?>(
          value: c.selectedVendorId.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Filter by vendor',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Vendors'),
            ),
            ...c.allVendors.map(
              (v) => DropdownMenuItem<String?>(
                value: v.vendorId,
                child: Text(v.vendorName, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: c.filterByVendor,
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Payable',
              style: GoogleFonts.rubik(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            Text(
              '₹${c.totalPayable.toStringAsFixed(2)}',
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.item});

  final VendorPayoutReportItem item;

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
                  item.vendorName,
                  style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              StatusBadge.forStatus(item.payoutStatus),
            ],
          ),
          const Divider(height: 20),
          _row('Total Sales', '₹${item.totalSalesAmount}'),
          const SizedBox(height: 6),
          _row('Commission (${item.commissionRate}%)',
              '- ₹${item.commissionAmount}'),
          const SizedBox(height: 6),
          _row('Payable Amount', '₹${item.payableAmount}', highlight: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint)),
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
