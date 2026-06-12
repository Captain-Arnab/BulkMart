import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/home/delivery_location_controller.dart';
import 'package:urban_roots/features/notifications/notifications_controller.dart';
import 'package:urban_roots/features/notifications/presentation/notifications_screen.dart';

class AppSearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onLocationTap;

  const AppSearchBarWidget({
    super.key,
    this.onLocationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(170);

  @override
  State<AppSearchBarWidget> createState() => _AppSearchBarWidgetState();
}

class _AppSearchBarWidgetState extends State<AppSearchBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellController;
  late final Animation<double> _bellSwing;
  late final Worker _unreadWorker;
  final _notifications = NotificationsController.findOrPut();
  final _location = DeliveryLocationController.findOrPut();

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

  Future<void> _showPincodeSheet() async {
    if (widget.onLocationTap != null) {
      widget.onLocationTap!();
      return;
    }

    final location = DeliveryLocationController.findOrPut();
    final pinController = TextEditingController(text: location.pincode.value);
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Delivery location',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter pincode to check delivery availability. City updates from your saved address when logged in.',
                      style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        counterText: '',
                      ),
                      validator: (value) {
                        final pin = value?.trim() ?? '';
                        if (pin.length != 6) return 'Enter a valid 6-digit pincode';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setSheetState(() => isSubmitting = true);
                              final error = await location.checkAndSetPincode(
                                pinController.text.trim(),
                              );
                              if (!context.mounted) return;
                              setSheetState(() => isSubmitting = false);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                                return;
                              }
                              Navigator.pop(context);
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Check availability'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: GestureDetector(
                    onTap: _showPincodeSheet,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            _location.city.value.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SizedBox(
              height: 50,
              child: TextField(
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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
          ),
        ],
      ),
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
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
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
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
