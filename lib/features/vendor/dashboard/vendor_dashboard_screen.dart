import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/analytics/vendor_analytics_screen.dart';
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
                case 'analytics':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorAnalyticsScreen(),
                    ),
                  );
                  break;
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
              PopupMenuItem(value: 'analytics', child: Text('Analytics')),
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
                childAspectRatio: 1.15,
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
                  VendorStatCard(
                    label: 'Total Revenue',
                    value: '₹${data?.totalRevenue ?? '0'}',
                    icon: Icons.trending_up_outlined,
                  ),
                  VendorStatCard(
                    label: 'Platform Commission',
                    value: '₹${data?.platformCommission ?? '0'}',
                    icon: Icons.percent_outlined,
                  ),
                  VendorStatCard(
                    label: 'Paid Out',
                    value: '₹${data?.paidOut ?? '0'}',
                    icon: Icons.check_circle_outline,
                  ),
                  VendorStatCard(
                    label: 'Orders This Month',
                    value: data?.ordersThisMonth ?? '0',
                    icon: Icons.calendar_month_outlined,
                  ),
                  VendorStatCard(
                    label: 'Pending Orders',
                    value: data?.pendingOrders ?? '0',
                    icon: Icons.pending_actions_outlined,
                  ),
                  VendorStatCard(
                    label: 'Total Products',
                    value: data?.totalProducts ?? '0',
                    icon: Icons.inventory_2_outlined,
                  ),
                  VendorStatCard(
                    label: 'Open Tickets',
                    value: data?.openTickets ?? '0',
                    icon: Icons.confirmation_number_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _BestSellingSection(products: data?.bestSelling ?? const []),
              const SizedBox(height: 20),
              _RecentPayoutsSection(payouts: data?.recentPayouts ?? const []),
              const SizedBox(height: 20),
              _ChartCard(
                title: 'Monthly Earnings',
                child: _MonthlyEarningsChart(
                  points: data?.monthlyEarnings ?? const [],
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
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorAnalyticsScreen(),
                    ),
                  );
                },
                child: const Text('View Analytics'),
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

class _RecentPayoutsSection extends StatelessWidget {
  const _RecentPayoutsSection({required this.payouts});

  final List<VendorPayout> payouts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Payouts',
                style:
                    GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorPaymentHistoryScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (payouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.cardTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No payouts yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(color: AppColors.hint),
            ),
          )
        else
          ...payouts.take(5).map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${p.amount}',
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            if (p.date.isNotEmpty)
                              Text(
                                p.date,
                                style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  color: AppColors.hint,
                                ),
                              ),
                          ],
                        ),
                      ),
                      StatusBadge.forStatus(p.status),
                    ],
                  ),
                ),
              ),
      ],
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

class _MonthlyEarningsChart extends StatelessWidget {
  const _MonthlyEarningsChart({required this.points});

  final List<MonthlyEarningsPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const ChartEmpty();
    final maxVal =
        points.fold<double>(0, (p, e) => e.amountValue > p ? e.amountValue : p);
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
                    toY: points[i].amountValue,
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
