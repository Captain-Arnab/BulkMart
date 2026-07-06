import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/products/presentation/widgets/product_cart_action.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String name;
  final String grams;
  final String stock;
  final String price;
  final String imageUrl;
  final String? offerLabel;
  final VoidCallback? onProductTap;
  final double imageHeight;
  final bool dense;

  const ProductCard({
    super.key,
    required this.name,
    required this.grams,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.id,
    this.offerLabel,
    this.onProductTap,
    this.imageHeight = 88,
    this.dense = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String get _productId => widget.id.toString();

  String get _displayImageUrl {
    if (widget.imageUrl.trim().isNotEmpty) {
      return resolveImageUrl(widget.imageUrl);
    }
    return '';
  }

  bool get _canAddToCart => widget.id > 0 && _productId.isNotEmpty;

  bool get _showGrams {
    final value = widget.grams.trim().toLowerCase();
    return value.isNotEmpty && value != '0' && value != '0g';
  }

  bool get _lowStock {
    final n = int.tryParse(widget.stock);
    return n != null && n < 30;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dense) return _buildDenseCard();
    return _buildStandardCard();
  }

  /// Blinkit-style compact card for 3-column home grids.
  Widget _buildDenseCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6ECE6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: widget.onProductTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surfaceMint,
                          AppColors.cardTint,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: NetworkOrAssetImage(
                        url: _displayImageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                if (widget.offerLabel != null &&
                    widget.offerLabel!.trim().isNotEmpty)
                  Positioned(
                    top: 7,
                    left: 7,
                    child: _badge(widget.offerLabel!, Colors.red.shade600),
                  ),
                if (_lowStock)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: _badge('Low', Colors.orange.shade700),
                  ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: -12,
                  child: ProductCartAction(
                    productId: _productId,
                    enabled: _canAddToCart,
                    mini: true,
                    inline: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
            child: GestureDetector(
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
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
                        fontSize: 9.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    '\u20B9${widget.price}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECE6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: widget.onProductTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surfaceMint,
                          AppColors.cardTint,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: NetworkOrAssetImage(
                        url: _displayImageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                if (widget.offerLabel != null &&
                    widget.offerLabel!.trim().isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge(widget.offerLabel!, Colors.red.shade600),
                  ),
                if (_lowStock)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _badge('Low', Colors.orange.shade700),
                  ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: -13,
                  child: ProductCartAction(
                    productId: _productId,
                    enabled: _canAddToCart,
                    compact: true,
                    inline: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: GestureDetector(
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
                      color: const Color(0xFF1A1A1A),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '\u20B9${widget.price}',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.dense ? 4 : 6,
        vertical: widget.dense ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(widget.dense ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.rubik(
          fontSize: widget.dense ? 6.5 : 8,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
