import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/notifications/notifications_controller.dart';
import 'package:urban_roots/features/notifications/presentation/notifications_screen.dart';

class AppSearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppSearchBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppSearchBarWidget> createState() => _AppSearchBarWidgetState();
}

class _AppSearchBarWidgetState extends State<AppSearchBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellController;
  late final Animation<double> _bellSwing;
  late final Worker _unreadWorker;
  final _notifications = NotificationsController.findOrPut();

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bellSwing = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.18, end: 0.18), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.18, end: -0.12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeInOut));

    _unreadWorker = ever(_notifications.unreadCount, _onUnreadCountChanged);
    _onUnreadCountChanged(_notifications.unreadCount.value);
  }

  void _onUnreadCountChanged(int count) {
    if (count > 0) {
      if (!_bellController.isAnimating) {
        _bellController.repeat(reverse: true);
      }
    } else {
      _bellController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _unreadWorker.dispose();
    _bellController.dispose();
    super.dispose();
  }

  Future<void> _openNotifications() async {
    _bellController.stop();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    await _notifications.refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 16,
      actionsPadding: const EdgeInsets.only(right: 4),
      title: SizedBox(
        height: 44,
        child: TextField(
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            suffixIcon: Icon(
              Icons.search,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            hintText: 'Search your products',
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: [
        Obx(() {
          final unread = _notifications.unreadCount.value;
          return _NotificationBellButton(
            unreadCount: unread,
            swing: _bellSwing,
            controller: _bellController,
            onTap: _openNotifications,
          );
        }),
      ],
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({
    required this.unreadCount,
    required this.swing,
    required this.controller,
    required this.onTap,
  });

  final int unreadCount;
  final Animation<double> swing;
  final AnimationController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: unreadCount > 0 ? swing.value : 0,
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
