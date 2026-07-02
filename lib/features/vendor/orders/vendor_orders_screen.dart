import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_orders_controller.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorOrdersController>();
    return DefaultTabController(
      length: VendorOrdersController.tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: Text('Orders',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            onTap: c.changeTab,
            tabs: VendorOrdersController.tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: Obx(() {
          if (c.isLoading.value && c.orders.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (c.errorMessage.value.isNotEmpty && c.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.errorMessage.value),
                  ElevatedButton(
                      onPressed: c.loadOrders, child: const Text('Retry')),
                ],
              ),
            );
          }
          return Stack(
            children: [
              if (c.orders.isEmpty)
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: c.loadOrders,
                  child: ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('No orders')),
                    ],
                  ),
                )
              else
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: c.loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: c.orders.length,
                    itemBuilder: (context, index) {
                      final order = c.orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${order.orderId}',
                                  style: GoogleFonts.rubik(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('${order.customerName} · ₹${order.amount}'),
                              const SizedBox(height: 4),
                              Chip(label: Text(order.status)),
                              if (order.isPending) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            c.cancelOrder(order.orderId),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () =>
                                            c.acceptOrder(order.orderId),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (order.isAccepted) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            c.cancelOrder(order.orderId),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () =>
                                            c.shipOrder(order.orderId),
                                        child: const Text('Ship'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (c.isLoading.value && c.orders.isNotEmpty)
                const ColoredBox(
                  color: Color(0x33FFFFFF),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
