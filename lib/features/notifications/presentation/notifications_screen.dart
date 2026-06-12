import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/notifications/domain/notifications_controller.dart';
import 'package:urban_roots/data/network/api_parsers.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  ApiViewStatus _status = ApiViewStatus.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = ApiViewStatus.loading);
    final result = await UrbanRootsApi.instance.notifications.list();
    if (!mounted) return;
    if (result is ApiFailure) {
      setState(() {
        _status = ApiViewStatus.error;
        _error = (result as ApiFailure).message;
      });
      return;
    }
    _items = extractList((result as ApiSuccess).data)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    setState(() => _status = _items.isEmpty ? ApiViewStatus.empty : ApiViewStatus.success);
    NotificationsController.findOrPut().refreshUnreadCount();
  }

  Future<void> _markRead(String id) async {
    await UrbanRootsApi.instance.notifications.markRead(notificationId: id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications', style: GoogleFonts.rubik(fontWeight: FontWeight.w600))),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _load,
        emptyMessage: 'No notifications',
        child: ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final n = _items[i];
            final isRead = n['is_read'] == 1 || n['is_read'] == true;
            return ListTile(
              tileColor: isRead ? null : Colors.green.shade50,
              title: Text(n['title']?.toString() ?? n['message']?.toString() ?? ''),
              subtitle: Text(n['created_at']?.toString() ?? ''),
              onTap: () => _markRead(n['notification_id']?.toString() ?? n['id']?.toString() ?? ''),
            );
          },
        ),
      ),
    );
  }
}
