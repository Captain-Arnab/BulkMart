import '../core/config/app_config.dart';
import '../data/mock/mock_notifications.dart';
import '../models/app_notification.dart';
import '../services/api/api_client.dart';
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
  ApiNotificationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ignore: unused_field — reserved for live notification endpoints
  final ApiClient _apiClient;

  @override
  Future<Result<List<AppNotification>>> fetchAll() async {
    throw UnimplementedError('ApiNotificationRepository.fetchAll');
  }

  @override
  Future<Result<List<AppNotification>>> markRead(String id) async {
    throw UnimplementedError('ApiNotificationRepository.markRead');
  }

  @override
  Future<Result<List<AppNotification>>> markAllRead() async {
    throw UnimplementedError('ApiNotificationRepository.markAllRead');
  }
}
