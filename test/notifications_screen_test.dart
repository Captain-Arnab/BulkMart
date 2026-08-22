import 'package:flutter_test/flutter_test.dart';
import 'package:veggiicart/models/app_notification.dart';

void main() {
  test('parse API created_at with space separator', () {
    final n = AppNotification.fromJson({
      'id': 19,
      'title': 'KYC approved',
      'body': 'Approved',
      'type': 'verification',
      'related_id': 15,
      'is_read': false,
      'created_at': '2026-08-19 09:10:33',
    });
    expect(n.createdAt.year, 2026);
    expect(n.createdAt.month, 8);
    expect(n.createdAt.day, 19);
    expect(n.createdAt.hour, 9);
    expect(n.kind.name, 'kyc');
  });
}
