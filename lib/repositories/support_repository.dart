import '../core/config/app_config.dart';
import '../models/support_ticket.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class SupportRepository {
  factory SupportRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) {
      return MockSupportRepository();
    }
    return ApiSupportRepository(apiClient: apiClient!);
  }

  Future<Result<List<SupportTicket>>> fetchTickets();

  Future<Result<SupportTicket>> submitTicket({
    required String subject,
    required String description,
    String? relatedOrderId,
  });
}

class MockSupportRepository implements SupportRepository {
  final List<SupportTicket> _tickets = [];

  @override
  Future<Result<List<SupportTicket>>> fetchTickets() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Success(List.unmodifiable(_tickets));
  }

  @override
  Future<Result<SupportTicket>> submitTicket({
    required String subject,
    required String description,
    String? relatedOrderId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (description.trim().isEmpty) {
      return const Failure('Please describe your issue');
    }
    final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
    final ticket = SupportTicket(
      id: 'SPT-$stamp',
      subject: subject.trim(),
      description: description.trim(),
      relatedOrderId: relatedOrderId,
      createdAt: DateTime.now(),
    );
    _tickets.insert(0, ticket);
    return Success(ticket);
  }
}

class ApiSupportRepository implements SupportRepository {
  ApiSupportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<List<SupportTicket>>> fetchTickets() async {
    try {
      final response =
          await _apiClient.dio.get(ApiEndpoints.supportTickets);
      return ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['tickets'] is List
            ? data['tickets'] as List
            : const [];
        return raw
            .map(
              (e) =>
                  SupportTicket.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<SupportTicket>> submitTicket({
    required String subject,
    required String description,
    String? relatedOrderId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.supportTickets,
        data: {
          'subject': subject.trim(),
          'subject_type': subject.trim(),
          'description': description.trim(),
          if (relatedOrderId != null && relatedOrderId.isNotEmpty)
            'related_order_id':
                int.tryParse(relatedOrderId) ?? relatedOrderId,
        },
      );
      return ApiEnvelope.parse(response, (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final raw = map['ticket'] ?? map;
        return SupportTicket.fromJson(Map<String, dynamic>.from(raw as Map));
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }
}
