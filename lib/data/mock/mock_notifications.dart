import '../../models/app_notification.dart';

class MockNotifications {
  MockNotifications._();

  static List<AppNotification> seed() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'Order out for delivery',
        body: 'Your order VC-10428 is out for delivery. Keep COD ready.',
        createdAt: now.subtract(const Duration(hours: 2)),
        kind: NotificationKind.order,
        read: false,
        orderId: 'VC-10428',
      ),
      AppNotification(
        id: 'n2',
        title: 'KYC approved',
        body: 'Your KYC application is approved. You can place wholesale orders.',
        createdAt: now.subtract(const Duration(days: 1)),
        kind: NotificationKind.kyc,
        read: false,
      ),
      AppNotification(
        id: 'n3',
        title: 'Seasonal offer live',
        body: 'Fresh greens bulk discount is live this week — open Offers for details.',
        createdAt: now.subtract(const Duration(days: 2)),
        kind: NotificationKind.offer,
        read: true,
        offerId: 'off_greens',
      ),
      AppNotification(
        id: 'n4',
        title: 'Order delivered',
        body: 'Order VC-10410 was marked delivered. Rate your experience anytime.',
        createdAt: now.subtract(const Duration(days: 4)),
        kind: NotificationKind.order,
        read: true,
        orderId: 'VC-10410',
      ),
    ];
  }
}
