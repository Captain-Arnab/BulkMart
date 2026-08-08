enum NotificationKind { order, offer, kyc, general }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.kind,
    this.read = false,
    this.orderId,
    this.offerId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationKind kind;
  final bool read;
  final String? orderId;
  final String? offerId;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      kind: kind,
      read: read ?? this.read,
      orderId: orderId,
      offerId: offerId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      kind: NotificationKind.values.firstWhere(
        (k) => k.name == (json['kind']?.toString() ?? 'general'),
        orElse: () => NotificationKind.general,
      ),
      read: json['read'] == true,
      orderId: json['order_id']?.toString() ?? json['orderId']?.toString(),
      offerId: json['offer_id']?.toString() ?? json['offerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'kind': kind.name,
        'read': read,
        if (orderId != null) 'order_id': orderId,
        if (offerId != null) 'offer_id': offerId,
      };
}
