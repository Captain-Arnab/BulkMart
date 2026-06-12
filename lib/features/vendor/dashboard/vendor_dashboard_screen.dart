import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/shimmer_widgets.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/dashboard/vendor_dashboard_view_model.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  late final VendorDashboardViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = VendorDashboardViewModel();
    _vm.addListener(() => setState(() {}));
    _vm.load(period: 'today');
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _vm.load(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Overview',
              style: GoogleFonts.rubik(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _PeriodChips(
              selected: _vm.selectedPeriod,
              onSelected: (p) => _vm.load(period: p),
            ),
            const SizedBox(height: 20),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final state = _vm.state;
    if (state is UiLoading) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.2,
        children: const [
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
        ],
      );
    }
    if (state is UiError<VendorDashboardStats>) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => _vm.load(), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final stats = (state as UiSuccess<VendorDashboardStats>).data;
    final currency = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.2,
      children: [
        VendorStatCard(
          label: 'Total Products',
          value: '${stats.totalProducts}',
          icon: Icons.inventory_2_outlined,
        ),
        VendorStatCard(
          label: 'Total Orders',
          value: '${stats.totalOrders}',
          icon: Icons.receipt_long_outlined,
        ),
        VendorStatCard(
          label: 'Pending Orders',
          value: '${stats.pendingOrders}',
          icon: Icons.pending_actions_outlined,
        ),
        VendorStatCard(
          label: 'Total Revenue',
          value: currency.format(stats.totalRevenue),
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('today', 'Today'),
      ('week', 'This Week'),
      ('month', 'This Month'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: options.map((o) {
          final isSelected = selected == o.$1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: o.$1 != 'month' ? 6 : 0),
              child: Material(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                elevation: isSelected ? 1 : 0,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                child: InkWell(
                  onTap: () => onSelected(o.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      o.$2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
