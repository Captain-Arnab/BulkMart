import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/features/catalog/presentation/search_screen.dart';
import 'package:urban_roots/features/home/delivery_location_controller.dart';
import 'package:urban_roots/features/notifications/notifications_controller.dart';
import 'package:urban_roots/features/notifications/presentation/notifications_screen.dart';
import 'package:urban_roots/features/offers/presentation/offers_screen.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';

class AppSearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppSearchBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(112);

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
    _location.resolve();
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

  Future<void> _openCategories() async {
    final controller = Get.put(ProductsController());
    await controller.fetchCategories();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Categories',
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final id = int.tryParse(cat.id) ?? 0;
                      return ListTile(
                        leading: Icon(categoryFallbackIcon(cat.name)),
                        title: Text(cat.name),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductPage(
                                category: id,
                                minPrice: 0,
                                maxPrice: 2000,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLocationSheet() async {
    final pinController = TextEditingController(text: _location.pincode.value);
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
                      'Delivery Location',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter pincode to check delivery availability.',
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
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
                        if (pin.length != 6) {
                          return 'Enter a valid 6-digit pincode';
                        }
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
                              final error = await _location.checkAndSetPincode(
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
                              setState(() {});
                              Navigator.pop(context);
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Location'),
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

  void _openOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OffersScreen()),
    );
  }

  Widget _headerChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rubik(
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 112,
      titleSpacing: 8,
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Obx(
              () => Row(
                children: [
                  _headerChip(
                    icon: Icons.grid_view_rounded,
                    label: 'Categories',
                    subtitle: 'Browse',
                    onTap: _openCategories,
                  ),
                  _headerChip(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    subtitle: _location.city.value.toUpperCase(),
                    onTap: _showLocationSheet,
                  ),
                  _headerChip(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers',
                    subtitle: 'Deals',
                    onTap: _openOffers,
                  ),
                  _NotificationBellButton(
                    unreadCount: _notifications.unreadCount.value,
                    swing: _bellSwing,
                    controller: _bellController,
                    onTap: _openNotifications,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 14),
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
          padding: const EdgeInsets.all(6),
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
                  size: 24,
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
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 8,
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
