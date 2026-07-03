import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/analytics/vendor_analytics_screen.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_dashboard_controller.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_orders_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';
import 'package:urban_roots/features/vendor/payments/vendor_payment_history_screen.dart';
import 'package:urban_roots/features/vendor/support/vendor_ticket_list_screen.dart';
import 'package:urban_roots/features/vendor/widgets/vendor_api_debug_copy_button.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorDashboardController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(() {
        if (c.isLoading.value && c.dashboard.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (c.errorMessage.value.isNotEmpty && c.dashboard.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const VendorApiDebugCopyButton(),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: c.load, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final data = c.dashboard.value;
        final analytics = c.analytics.value;

        void goToTab(int index) => VendorShell.switchTab?.call(index);
        void goToOrdersTab(int orderTabIndex) {
          VendorShell.switchTab?.call(2);
          Get.find<VendorOrdersController>().changeTab(orderTabIndex);
        }
        void pushScreen(Widget screen) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.scaffold,
                foregroundColor: Colors.black87,
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    tooltip: 'Full analytics',
                    onPressed: () =>
                        pushScreen(const VendorAnalyticsScreen()),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'payouts':
                          pushScreen(const VendorPaymentHistoryScreen());
                        case 'support':
                          pushScreen(const VendorTicketListScreen());
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'payouts', child: Text('Payout History')),
                      PopupMenuItem(value: 'support', child: Text('Support')),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _HeroCard(
                      isOpen: c.isOpen.value,
                      isToggling: c.isTogglingAvailability.value,
                      onToggle: c.toggleAvailability,
                      totalEarnings: data?.totalEarnings ?? '0',
                      revenueToday: data?.revenue ?? '0',
                      pendingPayout: data?.pendingPayout ?? '0',
                      onEarningsTap: () => goToTab(3),
                      onPayoutTap: () =>
                          pushScreen(const VendorPaymentHistoryScreen()),
                    ),
                    const SizedBox(height: 20),
                    _QuickActions(
                      onOrders: () => goToOrdersTab(0),
                      onProducts: () => goToTab(1),
                      onEarnings: () => goToTab(3),
                      onAnalytics: () =>
                          pushScreen(const VendorAnalyticsScreen()),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle('Analytics'),
                    const SizedBox(height: 12),
                    _AnalyticsPanel(
                      monthlyRevenue:
                          analytics?.monthlyRevenue ?? const [],
                      orderStatus:
                          analytics?.orderStatus ?? const OrderStatusBreakdown(),
                      monthlyEarnings: data?.monthlyEarnings ?? const [],
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle('Overview'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 108,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _MetricChip(
                            label: 'Orders Today',
                            value: data?.ordersToday ?? '0',
                            icon: Icons.receipt_long_outlined,
                            onTap: () => goToOrdersTab(0),
                          ),
                          _MetricChip(
                            label: 'Pending',
                            value: data?.pendingOrders ?? '0',
                            icon: Icons.pending_actions_outlined,
                            accent: const Color(0xFFE08600),
                            onTap: () => goToOrdersTab(1),
                          ),
                          _MetricChip(
                            label: 'This Month',
                            value: data?.ordersThisMonth ?? '0',
                            icon: Icons.calendar_month_outlined,
                            onTap: () => goToOrdersTab(0),
                          ),
                          _MetricChip(
                            label: 'Products',
                            value: data?.totalProducts ?? '0',
                            icon: Icons.inventory_2_outlined,
                            onTap: () => goToTab(1),
                          ),
                          _MetricChip(
                            label: 'Total Revenue',
                            value: '₹${data?.totalRevenue ?? '0'}',
                            icon: Icons.trending_up_outlined,
                            onTap: () =>
                                pushScreen(const VendorAnalyticsScreen()),
                          ),
                          _MetricChip(
                            label: 'Commission',
                            value: '₹${data?.platformCommission ?? '0'}',
                            icon: Icons.percent_outlined,
                            onTap: () =>
                                pushScreen(const VendorAnalyticsScreen()),
                          ),
                          _MetricChip(
                            label: 'Paid Out',
                            value: '₹${data?.paidOut ?? '0'}',
                            icon: Icons.check_circle_outline,
                            onTap: () =>
                                pushScreen(const VendorPaymentHistoryScreen()),
                          ),
                          _MetricChip(
                            label: 'Tickets',
                            value: data?.openTickets ?? '0',
                            icon: Icons.confirmation_number_outlined,
                            accent: const Color(0xFFD32F2F),
                            onTap: () =>
                                pushScreen(const VendorTicketListScreen()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _BestSellingSection(
                      products: data?.bestSelling ?? const [],
                      onProductsTap: () => goToTab(1),
                    ),
                    const SizedBox(height: 22),
                    _RecentPayoutsSection(
                      payouts: data?.recentPayouts ?? const [],
                      onViewAll: () =>
                          pushScreen(const VendorPaymentHistoryScreen()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.rubik(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isOpen,
    required this.isToggling,
    required this.onToggle,
    required this.totalEarnings,
    required this.revenueToday,
    required this.pendingPayout,
    required this.onEarningsTap,
    required this.onPayoutTap,
  });

  final bool isOpen;
  final bool isToggling;
  final ValueChanged<bool> onToggle;
  final String totalEarnings;
  final String revenueToday;
  final String pendingPayout;
  final VoidCallback onEarningsTap;
  final VoidCallback onPayoutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.insights_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.lightGreenAccent : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'Store Open' : 'Store Closed',
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isToggling)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: isOpen,
                          onChanged: onToggle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Total Earnings',
                  style: GoogleFonts.rubik(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onEarningsTap,
                  child: Text(
                    '₹$totalEarnings',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        label: "Today's Revenue",
                        value: '₹$revenueToday',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white24,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: onPayoutTap,
                        child: _HeroStat(
                          label: 'Pending Payout',
                          value: '₹$pendingPayout',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.rubik(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onOrders,
    required this.onProducts,
    required this.onEarnings,
    required this.onAnalytics,
  });

  final VoidCallback onOrders;
  final VoidCallback onProducts;
  final VoidCallback onEarnings;
  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.receipt_long_rounded,
            label: 'Orders',
            onTap: onOrders,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.inventory_2_rounded,
            label: 'Products',
            onTap: onProducts,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Earnings',
            onTap: onEarnings,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.bar_chart_rounded,
            label: 'Analytics',
            onTap: onAnalytics,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 130,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  const _AnalyticsPanel({
    required this.monthlyRevenue,
    required this.orderStatus,
    required this.monthlyEarnings,
  });

  final List<MonthlyRevenuePoint> monthlyRevenue;
  final OrderStatusBreakdown orderStatus;
  final List<MonthlyEarningsPoint> monthlyEarnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModernCard(
          title: 'Monthly Revenue',
          subtitle: 'From analytics',
          child: _RevenueLineChart(points: monthlyRevenue),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ModernCard(
                title: 'Order Status',
                child: _OrderDonutChart(breakdown: orderStatus),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ModernCard(
                title: 'Earnings',
                subtitle: 'Monthly',
                child: _MiniBarChart(points: monthlyEarnings),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernCard extends StatelessWidget {
  const _ModernCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Text(
                  subtitle!,
                  style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart({required this.points});
  final List<MonthlyRevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const ChartEmpty(height: 160);
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].revenueValue),
    ];
    final maxY = spots.fold<double>(0, (p, s) => s.y > p ? s.y : p);
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  _compact(v),
                  style: GoogleFonts.rubik(fontSize: 9, color: AppColors.hint),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox();
                  return Text(
                    points[i].month.length > 4
                        ? points[i].month.substring(0, 3)
                        : points[i].month,
                    style: GoogleFonts.rubik(fontSize: 9, color: AppColors.hint),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compact(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}

class _OrderDonutChart extends StatelessWidget {
  const _OrderDonutChart({required this.breakdown});
  final OrderStatusBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const ChartEmpty(height: 140);
    final segments = <_Seg>[
      _Seg('Pending', breakdown.pending, const Color(0xFFE08600)),
      _Seg('Accepted', breakdown.accepted, const Color(0xFF1976D2)),
      _Seg('Delivered', breakdown.delivered, AppColors.primary),
      _Seg('Cancelled', breakdown.cancelled, const Color(0xFFD32F2F)),
    ].where((s) => s.value > 0).toList();
    return SizedBox(
      height: 140,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 32,
          sections: [
            for (final s in segments)
              PieChartSectionData(
                value: s.value,
                color: s.color,
                radius: 40,
                title: '${s.value.toStringAsFixed(0)}',
                titleStyle: GoogleFonts.rubik(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.points});
  final List<MonthlyEarningsPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const ChartEmpty(height: 140);
    final maxVal =
        points.fold<double>(0, (p, e) => e.amountValue > p ? e.amountValue : p);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.2;
    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].amountValue,
                    color: AppColors.primary,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _BestSellingSection extends StatelessWidget {
  const _BestSellingSection({
    required this.products,
    required this.onProductsTap,
  });

  final List<BestSellingProduct> products;
  final VoidCallback onProductsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Best Selling',
                style: GoogleFonts.rubik(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onProductsTap, child: const Text('Products')),
          ],
        ),
        const SizedBox(height: 10),
        if (products.isEmpty)
          _EmptyPanel('No sales data yet')
        else
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = products[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        AppColors.surfaceMint,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded,
                              color: AppColors.primary, size: 18),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        p.name.isEmpty ? 'Product' : p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        '${p.totalSold} sold · ₹${p.revenue}',
                        style: GoogleFonts.rubik(
                            fontSize: 11, color: AppColors.hint),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RecentPayoutsSection extends StatelessWidget {
  const _RecentPayoutsSection({
    required this.payouts,
    required this.onViewAll,
  });

  final List<VendorPayout> payouts;
  final VoidCallback onViewAll;

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
                style: GoogleFonts.rubik(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 10),
        if (payouts.isEmpty)
          _EmptyPanel('No payouts yet')
        else
          ...payouts.take(3).map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.payments_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
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

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.rubik(color: AppColors.hint),
      ),
    );
  }
}

class _Seg {
  const _Seg(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}
