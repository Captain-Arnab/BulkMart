import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart' show showAppToast;
import 'package:urban_roots/features/wishlist/wishlist_controller.dart';

/// Heart toggle that checks wishlist membership on load and optimistically
/// updates on tap (reverts if the API call fails).
class WishlistHeartButton extends StatefulWidget {
  const WishlistHeartButton({
    super.key,
    required this.productId,
    this.size = 22,
    this.padding = const EdgeInsets.all(6),
    this.filledColor,
    this.outlineColor,
    this.backgroundColor,
  });

  final String productId;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? filledColor;
  final Color? outlineColor;
  final Color? backgroundColor;

  @override
  State<WishlistHeartButton> createState() => _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends State<WishlistHeartButton> {
  late final WishlistController _wishlist;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _wishlist = WishlistController.findOrPut();
    _load();
  }

  Future<void> _load() async {
    final id = widget.productId.trim();
    if (id.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    await _wishlist.isInWishlist(id);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _onTap() async {
    final id = widget.productId.trim();
    if (id.isEmpty || _wishlist.isToggling(id)) return;

    final ok = await _wishlist.toggle(id);
    if (!ok && mounted) {
      showAppToast(
        context,
        _wishlist.errorMessage.value.isNotEmpty
            ? _wishlist.errorMessage.value
            : 'Could not update wishlist',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.productId.trim();
    if (id.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final inWishlist = _wishlist.isKnownInWishlist(id);
      final busy = _wishlist.isToggling(id) || _loading;

      return Material(
        color: widget.backgroundColor ?? Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 1.5,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : _onTap,
          child: Padding(
            padding: widget.padding,
            child: busy && _loading
                ? SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    inWishlist
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: widget.size,
                    color: inWishlist
                        ? (widget.filledColor ?? Colors.red.shade500)
                        : (widget.outlineColor ?? Colors.grey.shade700),
                  ),
          ),
        ),
      );
    });
  }
}
