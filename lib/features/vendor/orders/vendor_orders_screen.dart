import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_orders_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/widgets/vendor_api_debug_copy_button.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorOrdersController>();
    return Obx(() {
      final initialTab = c.selectedTab.value;
      return DefaultTabController(
        key: ValueKey(initialTab),
        length: VendorOrdersController.tabs.length,
        initialIndex: initialTab,
        child: Scaffold(
          backgroundColor: AppColors.scaffold,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.scaffold,
                foregroundColor: Colors.black87,
                elevation: 0,
                title: Text('Orders',
                    style: GoogleFonts.rubik(fontWeight: FontWeight.w700)),
                bottom: TabBar(
                  isScrollable: true,
                  onTap: c.changeTab,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.hint,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: VendorOrdersController.tabs
                      .map((t) => Tab(text: t))
                      .toList(),
                ),
              ),
            ],
            body: Obx(() {
              if (c.isLoading.value && c.orders.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (c.errorMessage.value.isNotEmpty && c.orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.errorMessage.value, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const VendorApiDebugCopyButton(),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: c.loadOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: c.loadOrders,
                    child: c.orders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              EmptyView(
                                icon: Icons.receipt_long_outlined,
                                message: 'No orders here',
                                subtitle:
                                    'Orders for this status will appear here.',
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                            itemCount: c.orders.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    '${c.orders.length} '
                                    '${c.orders.length == 1 ? 'order' : 'orders'}',
                                    style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      color: AppColors.hint,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                              final order = c.orders[index - 1];
                              return _OrderCard(order: order, controller: c);
                            },
                          ),
                  ),
                  if (c.isLoading.value && c.orders.isNotEmpty)
                    const ColoredBox(
                      color: Color(0x33FFFFFF),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.controller});

  final VendorOrderItem order;
  final VendorOrdersController controller;

  Color get _accent {
    final s = order.status.toLowerCase();
    if (s.contains('pending') || s.contains('placed')) {
      return const Color(0xFFE08600);
    }
    if (s.contains('accept')) return const Color(0xFF1976D2);
    if (s.contains('ship')) return AppColors.primary;
    if (s.contains('deliver') || s.contains('complet')) {
      return const Color(0xFF2E7D32);
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return const Color(0xFFD32F2F);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${order.orderId}',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        StatusBadge.forStatus(order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: AppColors.hint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.customerName,
                            style: GoogleFonts.rubik(fontSize: 13),
                          ),
                        ),
                        Text(
                          '₹${order.amount}',
                          style: GoogleFonts.rubik(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    if (order.isPending || order.isAccepted) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD32F2F),
                                side: BorderSide(
                                  color: const Color(0xFFD32F2F)
                                      .withValues(alpha: 0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  controller.cancelOrder(order.orderId),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (order.isPending) {
                                  controller.acceptOrder(order.orderId);
                                } else {
                                  controller.shipOrder(order.orderId);
                                }
                              },
                              child: Text(
                                  order.isPending ? 'Accept' : 'Ship'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
