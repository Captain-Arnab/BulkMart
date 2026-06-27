import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/admin/delivery_monitoring/admin_delivery_monitoring_screen.dart';
import 'package:urban_roots/features/admin/payout_report/admin_vendor_payout_report_screen.dart';
import 'package:urban_roots/features/admin/sales_summary/admin_vendor_sales_summary_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_AdminMenuItem>[
      _AdminMenuItem(
        title: 'Vendor Payout Report',
        subtitle: 'Commission & payable amounts per vendor',
        icon: Icons.account_balance_outlined,
        builder: (_) => const AdminVendorPayoutReportScreen(),
      ),
      _AdminMenuItem(
        title: 'Vendor Sales Summary',
        subtitle: 'Products sold and order stats',
        icon: Icons.bar_chart_rounded,
        builder: (_) => const AdminVendorSalesSummaryScreen(),
      ),
      _AdminMenuItem(
        title: 'Delivery Monitoring',
        subtitle: 'Real-time delivery boy status',
        icon: Icons.delivery_dining_outlined,
        builder: (_) => const AdminDeliveryMonitoringScreen(),
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Admin Panel',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: item.builder),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: GoogleFonts.rubik(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(item.subtitle,
                            style: GoogleFonts.rubik(
                                fontSize: 12.5, color: AppColors.hint)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.hint),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
