import '../core/config/app_config.dart';
import '../models/support_ticket.dart';
import '../services/api/api_client.dart';
import '../services/api/result.dart';

/// Support tickets. Demo vs live is controlled by [AppConfig.kDemoMode].
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

  // ignore: unused_field — reserved for live /support endpoints
  final ApiClient _apiClient;

  @override
  Future<Result<List<SupportTicket>>> fetchTickets() async {
    // TODO: Wire to GET /support/tickets when backend is ready.
    throw UnimplementedError('ApiSupportRepository.fetchTickets');
  }

  @override
  Future<Result<SupportTicket>> submitTicket({
    required String subject,
    required String description,
    String? relatedOrderId,
  }) async {
    // TODO: Wire to POST /support/tickets when backend is ready.
    throw UnimplementedError('ApiSupportRepository.submitTicket');
  }
}
