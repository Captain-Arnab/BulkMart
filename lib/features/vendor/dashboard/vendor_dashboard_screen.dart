import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/features/vendor/analytics/vendor_analytics_screen.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_dashboard_controller.dart';
import 'package:urban_roots/features/vendor/directory/vendor_directory_screen.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_shell.dart';

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
              if (value == 'directory') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorDirectoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'directory', child: Text('Vendor Directory')),
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
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorAnalyticsScreen(),
                  ),
                ),
                icon: const Icon(Icons.insights_rounded),
                label: const Text('View Analytics'),
              ),
              const SizedBox(height: 12),
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
            height: 130,
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
