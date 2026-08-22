import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;

  bool _inFlight = false;
  List<AppNotification> items = [];
  bool isLoading = false;
  String? error;

  int get unreadCount => items.where((n) => !n.read).length;

  Future<void> load({bool refresh = false}) async {
    if (_inFlight) return;
    if (!refresh && items.isNotEmpty) return;

    _inFlight = true;
    isLoading = items.isEmpty;
    error = null;
    notifyListeners();
    final result = await _repository.fetchAll();
    _inFlight = false;
    result.when(
      success: (list) {
        items = list;
        isLoading = false;
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {
        error = message;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markRead(String id) async {
    final result = await _repository.markRead(id);
    result.when(
      success: (list) {
        items = list;
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {},
    );
  }

  Future<void> markAllRead() async {
    final result = await _repository.markAllRead();
    result.when(
      success: (list) {
        items = list;
        notifyListeners();
      },
      failure: (message, {statusCode, code, fields}) {},
    );
  }
}
