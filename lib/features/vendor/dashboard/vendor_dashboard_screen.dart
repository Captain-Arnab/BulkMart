import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF019934),
        onRefresh: () => _vm.load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PeriodChips(
              selected: _vm.selectedPeriod,
              onSelected: (p) => _vm.load(period: p),
            ),
            const SizedBox(height: 16),
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
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
        child: Column(
          children: [
            Text(state.message, style: GoogleFonts.rubik(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => _vm.load(), child: const Text('Retry')),
          ],
        ),
      );
    }
    final stats = (state as UiSuccess<VendorDashboardStats>).data;
    final currency = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(label: 'Total Products', value: '${stats.totalProducts}', icon: Icons.inventory_2_outlined),
        _StatCard(label: 'Total Orders', value: '${stats.totalOrders}', icon: Icons.receipt_long_outlined),
        _StatCard(label: 'Pending Orders', value: '${stats.pendingOrders}', icon: Icons.pending_actions_outlined),
        _StatCard(label: 'Total Revenue', value: currency.format(stats.totalRevenue), icon: Icons.payments_outlined),
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
    return Row(
      children: options.map((o) {
        final isSelected = selected == o.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: o.$1 != 'month' ? 8 : 0),
            child: FilterChip(
              label: Text(o.$2, style: GoogleFonts.rubik(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onSelected(o.$1),
              selectedColor: const Color(0xFF019934).withValues(alpha: 0.15),
              checkmarkColor: const Color(0xFF019934),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF019934), size: 22),
            const Spacer(),
            Text(label, style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
