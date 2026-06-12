import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/wishlist/domain/wishlist_controller.dart';

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

    final cart = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: widget.onProductTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: NetworkOrAssetImage(
                        url: _displayImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: _isWishlistLoading ? null : toggleWishlist,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: _isWishlistLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  if (int.tryParse(widget.stock) != null && int.parse(widget.stock) < 30)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.shade600, borderRadius: BorderRadius.circular(6)),
                        child: Text('Low Stock', style: GoogleFonts.rubik(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
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
                          style: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.2),
                        ),
                        const SizedBox(height: 2),
                        Text(widget.grams, style: GoogleFonts.rubik(fontSize: 10, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\u20B9${widget.price}', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                      GestureDetector(
                        onTap: _isCartLoading || !_canAddToCart ? null : addToCart,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _canAddToCart ? const Color(0xFF019934) : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isCartLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
