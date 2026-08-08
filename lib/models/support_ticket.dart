class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    this.relatedOrderId,
    required this.createdAt,
    this.status = 'open',
  });

  final String id;
  final String subject;
  final String description;
  final String? relatedOrderId;
  final DateTime createdAt;
  final String status;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      relatedOrderId:
          json['related_order_id']?.toString() ?? json['relatedOrderId']?.toString(),
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'open',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'description': description,
        if (relatedOrderId != null) 'related_order_id': relatedOrderId,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };
}
