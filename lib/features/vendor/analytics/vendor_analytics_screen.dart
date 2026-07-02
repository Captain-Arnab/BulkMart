import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_analytics_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  late final VendorAnalyticsController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(VendorAnalyticsController());
  }

  @override
  void dispose() {
    Get.delete<VendorAnalyticsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Analytics',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.analytics.value == null) {
          return const LoadingView(label: 'Loading analytics...');
        }
        if (c.errorMessage.value.isNotEmpty && c.analytics.value == null) {
          return FailureView(message: c.errorMessage.value, onRetry: c.load);
        }
        final data = c.analytics.value;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                height: 130,
                child: Row(
                  children: [
                    Expanded(
                      child: VendorStatCard(
                        label: 'Total Earnings',
                        value: '₹${data?.totalEarnings ?? '0'}',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: VendorStatCard(
                        label: 'Pending Payout',
                        value: '₹${data?.pendingPayout ?? '0'}',
                        icon: Icons.schedule_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ChartCard(
                title: 'Monthly Revenue',
                child: _MonthlyRevenueChart(
                  points: data?.monthlyRevenue ?? const [],
                ),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Order Status Breakdown',
                child: _OrderStatusChart(
                  breakdown:
                      data?.orderStatus ?? const OrderStatusBreakdown(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Best Selling Products',
                style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if ((data?.bestSelling ?? const []).isEmpty)
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
                ...data!.bestSelling.map(
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
                                p.name.isEmpty ? 'Product' : p.name,
                                style: GoogleFonts.rubik(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${p.totalSold} sold · ₹${p.revenue}',
                                style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  color: AppColors.hint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
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
    final maxVal =
        points.fold<double>(0, (p, e) => e.revenueValue > p ? e.revenueValue : p);
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
