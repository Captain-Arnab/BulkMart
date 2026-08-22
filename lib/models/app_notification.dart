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

  static DateTime _parseCreatedAt(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ??
        DateTime.tryParse(value.replaceFirst(' ', 'T')) ??
        DateTime.now();
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['kind'] ?? 'general').toString();
    final kind = switch (type.toLowerCase()) {
      'order' || 'orders' => NotificationKind.order,
      'offer' || 'offers' || 'promo' => NotificationKind.offer,
      'kyc' || 'verification' => NotificationKind.kyc,
      _ => NotificationKind.values.firstWhere(
          (k) => k.name == type,
          orElse: () => NotificationKind.general,
        ),
    };
    final relatedId = json['related_id']?.toString();
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: _parseCreatedAt(json['created_at']),
      kind: kind,
      read: json['read'] == true ||
          json['is_read'] == true ||
          json['is_read']?.toString() == '1',
      orderId: json['order_id']?.toString() ??
          json['orderId']?.toString() ??
          (kind == NotificationKind.order ? relatedId : null),
      offerId: json['offer_id']?.toString() ??
          json['offerId']?.toString() ??
          (kind == NotificationKind.offer ? relatedId : null),
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
