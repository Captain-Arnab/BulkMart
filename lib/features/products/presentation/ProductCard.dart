import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/wishlist/wishlist_controller.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String name;
  final String grams;
  final String stock;
  final String price;
  final String imageUrl;
  final VoidCallback? onProductTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.grams,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.id,
    this.onProductTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool _isWishlistLoading = false;
  bool _isCartLoading = false;

  String get _productId => widget.id.toString();

  String get _displayImageUrl {
    if (widget.imageUrl.trim().isNotEmpty) {
      return resolveImageUrl(widget.imageUrl);
    }
    return '';
  }

  bool get _canAddToCart => widget.id > 0 && _productId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadWishlistState();
  }

  Future<void> _loadWishlistState() async {
    final inList = await WishlistController.findOrPut().isInWishlist(_productId);
    if (mounted) setState(() => isFavorite = inList);
  }

  Future<void> addToCart() async {
    if (_isCartLoading || !_canAddToCart) return;
    setState(() => _isCartLoading = true);

    final cart = CartController.findOrPut();
    final success = await cart.addProduct(_productId);

    if (!mounted) return;
    setState(() => _isCartLoading = false);

    if (success) {
      await SweetAlert.success(context, message: '${widget.name} added to cart');
    } else {
      final message = cart.errorMessage.value;
      await SweetAlert.error(
        context,
        message: message.toLowerCase().contains('not found')
            ? 'This product is unavailable. Please try another item.'
            : (message.isNotEmpty ? message : 'Could not add to cart'),
      );
    }
  }

  Future<void> toggleWishlist() async {
    if (_isWishlistLoading) return;
    setState(() => _isWishlistLoading = true);

    final wishlist = WishlistController.findOrPut();
    final nextAdd = !isFavorite;
    final success = await wishlist.toggle(_productId, add: nextAdd);

    if (!mounted) return;
    setState(() => _isWishlistLoading = false);

    if (success) {
      setState(() => isFavorite = nextAdd);
      await SweetAlert.success(
        context,
        message: nextAdd ? 'Added to wishlist' : 'Removed from wishlist',
      );
    } else {
      await SweetAlert.error(
        context,
        message: wishlist.errorMessage.value.isNotEmpty
            ? wishlist.errorMessage.value
            : 'Could not update wishlist',
      );
    }
  }

  bool get _showGrams {
    final value = widget.grams.trim().toLowerCase();
    return value.isNotEmpty && value != '0' && value != '0g';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.softCard(radius: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onProductTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.cardTint,
                    child: NetworkOrAssetImage(
                      url: _displayImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _isWishlistLoading ? null : toggleWishlist,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: AppDecorations.glassCircle(),
                        child: _isWishlistLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: isFavorite ? Colors.red : Colors.grey.shade600,
                              ),
                      ),
                    ),
                  ),
                  if (int.tryParse(widget.stock) != null &&
                      int.parse(widget.stock) < 30)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Low Stock',
                          style: GoogleFonts.rubik(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onProductTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      if (_showGrams) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.grams,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '\u20B9${widget.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Material(
                      color: _canAddToCart
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      child: InkWell(
                        onTap: _isCartLoading || !_canAddToCart ? null : addToCart,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: _isCartLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
