import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/admin/controllers/admin_sales_summary_controller.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';

class AdminVendorSalesSummaryScreen extends StatefulWidget {
  const AdminVendorSalesSummaryScreen({super.key});

  @override
  State<AdminVendorSalesSummaryScreen> createState() =>
      _AdminVendorSalesSummaryScreenState();
}

class _AdminVendorSalesSummaryScreenState
    extends State<AdminVendorSalesSummaryScreen> {
  late final AdminSalesSummaryController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(AdminSalesSummaryController());
  }

  @override
  void dispose() {
    Get.delete<AdminSalesSummaryController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Vendor Sales Summary',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.summary.isEmpty) {
          return const LoadingView(label: 'Loading summary...');
        }
        if (c.errorMessage.value.isNotEmpty && c.summary.isEmpty) {
          return FailureView(message: c.errorMessage.value, onRetry: c.load);
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: c.summary.isEmpty
              ? const EmptyView(
                  icon: Icons.storefront_outlined,
                  message: 'No sales data',
                  subtitle: 'Vendor sales will appear here.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ChartCard(top: c.topFive),
                    const SizedBox(height: 16),
                    Text(
                      'All Vendors',
                      style: GoogleFonts.rubik(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...c.summary.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SummaryRow(item: s),
                        )),
                  ],
                ),
        );
      }),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.top});

  final List<VendorSalesSummaryItem> top;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Vendors by Products Sold',
            style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (top.isEmpty)
            const ChartEmpty()
          else
            SizedBox(height: 240, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final maxVal = top.fold<double>(
        0, (p, e) => e.productsSoldValue > p ? e.productsSoldValue : p);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.2;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.toStringAsFixed(0)} sold',
              GoogleFonts.rubik(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(0),
                style: GoogleFonts.rubik(fontSize: 10, color: AppColors.hint),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= top.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SizedBox(
                    width: 56,
                    child: Text(
                      top[i].vendorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.rubik(fontSize: 9.5, color: AppColors.hint),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < top.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: top[i].productsSoldValue,
                  color: AppColors.primary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.item});

  final VendorSalesSummaryItem item;

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
          Text(
            item.vendorName,
            style: GoogleFonts.rubik(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric('Products Sold', item.totalProductsSold,
                  Icons.inventory_2_outlined),
              _metric('Incoming', item.totalIncomingOrders,
                  Icons.move_to_inbox_outlined),
              _metric('Completed', item.totalCompletedOrders,
                  Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.rubik(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
          ),
        ],
      ),
    );
  }
}
