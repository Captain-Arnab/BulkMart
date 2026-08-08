import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/app_notification.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/notification_view_model.dart';
import '../../widgets/ui_states.dart';
import '../offers/offers_screen.dart';
import '../orders/order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  Future<void> _open(AppNotification n) async {
    final vm = context.read<NotificationViewModel>();
    await vm.markRead(n.id);
    if (!mounted) return;
    if (n.orderId != null && n.orderId!.isNotEmpty) {
      await AppPageRoute.push(context, OrderDetailScreen(orderId: n.orderId!));
    } else if (n.kind == NotificationKind.offer || n.offerId != null) {
      await AppPageRoute.push(context, const OffersScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final fmt = DateFormat('d MMM · h:mm a');

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        title: Text('Notifications', style: AppTextStyles.display(fontSize: 18)),
        actions: [
          if (vm.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ),
        ],
      ),
      body: vm.isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.green),
              ),
            )
          : vm.items.isEmpty
              ? const EmptyState(
                  title: 'All caught up',
                  subtitle: 'Order updates and offers will show up here.',
                  icon: Icons.notifications_none_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: vm.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = vm.items[index];
                    return PressableScale(
                      onTap: () => _open(n),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.read ? AppColors.white : AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(
                            color: n.read ? AppColors.line : AppColors.green.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Icon(_iconFor(n.kind), color: AppColors.green, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: AppTextStyles.body(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.body,
                                    style: AppTextStyles.body(
                                      fontSize: 13,
                                      color: AppColors.muted,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    fmt.format(n.createdAt),
                                    style: AppTextStyles.body(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (index * 35).ms).fadeIn(duration: 200.ms);
                  },
                ),
    );
  }

  IconData _iconFor(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.order => Icons.local_shipping_outlined,
      NotificationKind.offer => Icons.local_offer_outlined,
      NotificationKind.kyc => Icons.verified_outlined,
      NotificationKind.general => Icons.notifications_outlined,
    };
  }
}
