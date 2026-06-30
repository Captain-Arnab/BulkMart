import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_dashboard_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';
import 'package:urban_roots/features/vendor/payments/vendor_payment_history_screen.dart';
import 'package:urban_roots/features/vendor/support/vendor_ticket_list_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorDashboardController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'payouts':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorPaymentHistoryScreen(),
                    ),
                  );
                  break;
                case 'support':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorTicketListScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'payouts', child: Text('Payout History')),
              PopupMenuItem(value: 'support', child: Text('Support')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.dashboard.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (c.errorMessage.value.isNotEmpty && c.dashboard.value == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.errorMessage.value, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: c.load, child: const Text('Retry')),
              ],
            ),
          );
        }
        final data = c.dashboard.value;
        final analytics = c.analytics.value;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c.isOpen.value ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.isOpen.value ? 'Store Open' : 'Store Closed',
                    style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (c.isTogglingAvailability.value)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: c.isOpen.value,
                      activeColor: AppColors.primary,
                      onChanged: c.toggleAvailability,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: [
                  VendorStatCard(
                    label: 'Orders Today',
                    value: data?.ordersToday ?? '0',
                    icon: Icons.receipt_long_outlined,
                  ),
                  VendorStatCard(
                    label: 'Revenue',
                    value: '₹${data?.revenue ?? '0'}',
                    icon: Icons.payments_outlined,
                  ),
                  VendorStatCard(
                    label: 'Total Earnings',
                    value: '₹${data?.totalEarnings ?? '0'}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  VendorStatCard(
                    label: 'Pending Payout',
                    value: '₹${data?.pendingPayout ?? '0'}',
                    icon: Icons.schedule_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _BestSellingSection(products: data?.bestSelling ?? const []),
              const SizedBox(height: 20),
              _ChartCard(
                title: 'Monthly Revenue',
                child: _MonthlyRevenueChart(
                  points: analytics?.monthlyRevenue ?? const [],
                ),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Order Status Breakdown',
                child: _OrderStatusChart(
                  breakdown:
                      analytics?.orderStatus ?? const OrderStatusBreakdown(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => VendorShell.switchTab?.call(2),
                child: const Text('View Orders'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => VendorShell.switchTab?.call(1),
                child: const Text('Manage Products'),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _BestSellingSection extends StatelessWidget {
  const _BestSellingSection({required this.products});

  final List<BestSellingProduct> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Selling Products',
          style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.cardTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No sales data yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(color: AppColors.hint),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _BestSellingCard(product: products[i]),
            ),
          ),
      ],
    );
  }
}

class _BestSellingCard extends StatelessWidget {
  const _BestSellingCard({required this.product});

  final BestSellingProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_rounded,
                color: AppColors.primary, size: 20),
          ),
          const Spacer(),
          Text(
            product.name.isEmpty ? 'Product' : product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.totalSold} sold',
            style: GoogleFonts.rubik(fontSize: 12, color: AppColors.hint),
          ),
          Text(
            '₹${product.revenue}',
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            title,
            style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MonthlyRevenueChart extends StatelessWidget {
  const _MonthlyRevenueChart({required this.points});

  final List<MonthlyRevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const ChartEmpty();
    final maxVal = points.fold<double>(
        0, (p, e) => e.revenueValue > p ? e.revenueValue : p);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.2;
    return SizedBox(
      height: 220,
      child: BarChart(
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
                '₹${rod.toY.toStringAsFixed(0)}',
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
                reservedSize: 44,
                getTitlesWidget: (value, _) => Text(
                  _compact(value),
                  style: GoogleFonts.rubik(fontSize: 10, color: AppColors.hint),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      points[i].month,
                      style:
                          GoogleFonts.rubik(fontSize: 10, color: AppColors.hint),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].revenueValue,
                    color: AppColors.primary,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _compact(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _OrderStatusChart extends StatelessWidget {
  const _OrderStatusChart({required this.breakdown});

  final OrderStatusBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const ChartEmpty();
    final segments = <_Seg>[
      _Seg('Pending', breakdown.pending, const Color(0xFFE08600)),
      _Seg('Accepted', breakdown.accepted, const Color(0xFF1976D2)),
      _Seg('Delivered', breakdown.delivered, AppColors.primary),
      _Seg('Cancelled', breakdown.cancelled, const Color(0xFFD32F2F)),
    ].where((s) => s.value > 0).toList();
    final total = breakdown.total;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 44,
              sections: [
                for (final s in segments)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: 58,
                    title: '${(s.value / total * 100).toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final s in segments)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: s.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${s.label} (${s.value.toStringAsFixed(0)})',
                    style: GoogleFonts.rubik(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Seg {
  const _Seg(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}
