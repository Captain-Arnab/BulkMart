import '../core/config/app_config.dart';
import '../data/mock/mock_notifications.dart';
import '../models/app_notification.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_envelope.dart';
import '../services/api/result.dart';

abstract class NotificationRepository {
  factory NotificationRepository({ApiClient? apiClient}) {
    if (AppConfig.kDemoMode) return MockNotificationRepository();
    return ApiNotificationRepository(apiClient: apiClient!);
  }

  Future<Result<List<AppNotification>>> fetchAll();
  Future<Result<List<AppNotification>>> markRead(String id);
  Future<Result<List<AppNotification>>> markAllRead();
}

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository() : _items = MockNotifications.seed();

  final List<AppNotification> _items;

  @override
  Future<Result<List<AppNotification>>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Success(List.unmodifiable(_items));
  }

  @override
  Future<Result<List<AppNotification>>> markRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(read: true);
    return Success(List.unmodifiable(_items));
  }

  @override
  Future<Result<List<AppNotification>>> markAllRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
    return Success(List.unmodifiable(_items));
  }
}

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  List<AppNotification> _cache = [];

  @override
  Future<Result<List<AppNotification>>> fetchAll() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.notifications);
      return ApiEnvelope.parse(response, (data) {
        final raw = data is Map && data['notifications'] is List
            ? data['notifications'] as List
            : const [];
        _cache = raw
            .map(
              (e) => AppNotification.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        return List.unmodifiable(_cache);
      });
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<AppNotification>>> markRead(String id) async {
    try {
      final response =
          await _apiClient.dio.post(ApiEndpoints.notificationRead(id));
      final parsed = ApiEnvelope.parse(response, (_) => null);
      if (parsed is Failure<Null>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      _cache = _cache
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList();
      return Success(List.unmodifiable(_cache));
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }

  @override
  Future<Result<List<AppNotification>>> markAllRead() async {
    try {
      final response =
          await _apiClient.dio.post(ApiEndpoints.notificationsReadAll);
      final parsed = ApiEnvelope.parse(response, (_) => null);
      if (parsed is Failure<Null>) {
        return Failure(
          parsed.message,
          statusCode: parsed.statusCode,
          code: parsed.code,
          fields: parsed.fields,
        );
      }
      _cache = _cache.map((n) => n.copyWith(read: true)).toList();
      return Success(List.unmodifiable(_cache));
    } catch (e) {
      return ApiEnvelope.fromDio(e);
    }
  }
}
