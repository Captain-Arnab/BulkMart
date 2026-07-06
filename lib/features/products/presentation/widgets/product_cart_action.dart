import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart' show showAppToast;
import 'package:urban_roots/features/cart/cart_controller.dart';

/// Blinkit-style add-to-cart control: shows ADD when not in cart,
/// compact quantity stepper when the product is already in cart.
class ProductCartAction extends StatefulWidget {
  const ProductCartAction({
    super.key,
    required this.productId,
    this.compact = true,
    this.mini = false,
    this.inline = false,
    this.enabled = true,
  });

  final String productId;
  final bool compact;
  final bool mini;
  final bool inline;
  final bool enabled;

  @override
  State<ProductCartAction> createState() => _ProductCartActionState();
}

class _ProductCartActionState extends State<ProductCartAction> {
  bool _isLoading = false;

  CartController get _cart => CartController.findOrPut();

  bool get _canInteract =>
      widget.enabled && widget.productId.trim().isNotEmpty && !_isLoading;

  Future<void> _add() async {
    if (!_canInteract) return;
    setState(() => _isLoading = true);
    final success = await _cart.addProduct(widget.productId);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!success && mounted) {
      _showError(_cart.errorMessage.value);
    }
  }

  Future<void> _changeQuantity(int newQty) async {
    if (!_canInteract) return;
    final cartItemId = _cart.cartItemIdForProduct(widget.productId);
    if (cartItemId == null || cartItemId.isEmpty) return;

    setState(() => _isLoading = true);
    final success = await _cart.updateQuantity(cartItemId, newQty);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!success && mounted) {
      _showError(_cart.errorMessage.value);
    }
  }

  void _showError(String message) {
    showAppToast(
      context,
      message.isNotEmpty ? message : 'Could not update cart',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = _cart.quantityForProduct(widget.productId);
      final cartItemId = _cart.cartItemIdForProduct(widget.productId) ?? '';
      final isUpdating = _isLoading ||
          (cartItemId.isNotEmpty &&
              _cart.updatingItemId.value == cartItemId);

      if (qty > 0) {
        return _QuantityControl(
          quantity: qty,
          compact: widget.compact,
          mini: widget.mini,
          inline: widget.inline,
          isLoading: isUpdating,
          onDecrement: () => _changeQuantity(qty - 1),
          onIncrement: () => _changeQuantity(qty + 1),
        );
      }

      return _AddButton(
        compact: widget.compact,
        mini: widget.mini,
        inline: widget.inline,
        enabled: _canInteract,
        isLoading: isUpdating,
        onTap: _add,
      );
    });
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.compact,
    required this.mini,
    required this.inline,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  final bool compact;
  final bool mini;
  final bool inline;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = mini ? 22.0 : (compact ? 32.0 : 36.0);
    final minWidth = mini ? (inline ? 52.0 : 0.0) : (compact ? 64.0 : 72.0);
    final fontSize = mini ? 9.0 : (compact ? 12.0 : 13.0);
    final hPad = mini ? (inline ? 6.0 : 4.0) : (compact ? 10.0 : 14.0);
    final vPad = mini ? 3.0 : (compact ? 6.0 : 8.0);
    final radius = mini ? 7.0 : 10.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      elevation: mini ? 3 : 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      child: InkWell(
        onTap: enabled && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: inline
              ? double.infinity
              : (mini && !inline ? double.infinity : null),
          constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: enabled ? AppColors.primary : Colors.grey.shade300,
              width: mini ? 1.2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: mini ? 12 : 16,
                  height: mini ? 12 : 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: enabled ? AppColors.primary : Colors.grey,
                  ),
                )
              : Text(
                  'ADD',
                  style: GoogleFonts.rubik(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: enabled ? AppColors.primary : Colors.grey.shade400,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.compact,
    required this.mini,
    required this.inline,
    required this.isLoading,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final bool compact;
  final bool mini;
  final bool inline;
  final bool isLoading;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final height = mini ? 22.0 : (compact ? 32.0 : 36.0);
    final iconSize = mini ? 11.0 : (compact ? 16.0 : 18.0);
    final qtyFontSize = mini ? 10.0 : (compact ? 13.0 : 14.0);
    final hPad = mini ? 2.0 : (compact ? 6.0 : 10.0);
    final radius = mini ? 7.0 : 10.0;
    final tapPadH = inline ? (compact ? 2.0 : 1.0) : 6.0;
    final tapPadV = inline ? (compact ? 1.0 : 2.0) : 4.0;

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      elevation: mini ? 3 : 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: inline ? double.infinity : null,
          child: inline
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _buildRow(
                    iconSize: iconSize,
                    qtyFontSize: qtyFontSize,
                    hPad: hPad,
                    tapPadH: tapPadH,
                    tapPadV: tapPadV,
                  ),
                )
              : _buildRow(
                  iconSize: iconSize,
                  qtyFontSize: qtyFontSize,
                  hPad: hPad,
                  tapPadH: tapPadH,
                  tapPadV: tapPadV,
                ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required double iconSize,
    required double qtyFontSize,
    required double hPad,
    required double tapPadH,
    required double tapPadV,
  }) {
    return Row(
      mainAxisSize: inline ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QtyTap(
          icon: Icons.remove_rounded,
          iconSize: iconSize,
          padH: tapPadH,
          padV: tapPadV,
          onTap: isLoading ? null : onDecrement,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: isLoading
              ? SizedBox(
                  width: mini ? 10 : 14,
                  height: mini ? 10 : 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                )
              : Text(
                  '$quantity',
                  style: GoogleFonts.rubik(
                    fontSize: qtyFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
        _QtyTap(
          icon: Icons.add_rounded,
          iconSize: iconSize,
          padH: tapPadH,
          padV: tapPadV,
          onTap: isLoading ? null : onIncrement,
        ),
      ],
    );
  }
}

class _QtyTap extends StatelessWidget {
  const _QtyTap({
    required this.icon,
    required this.iconSize,
    this.padH = 6,
    this.padV = 4,
    this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final double padH;
  final double padV;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Icon(
            icon,
            size: iconSize,
            color: onTap != null ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}
