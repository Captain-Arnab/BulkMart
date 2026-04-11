import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String name;
  final String grams;
  final String stock;
  final String price;
  final String imageUrl;

  const ProductCard({
    Key? key,
    required this.name,
    required this.grams,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.id,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  String get _assetImage => DummyData.getProductImage(widget.id.toString());

  void addToCart() {
    bool found = false;
    for (var item in DummyData.cartItems) {
      if (item['product_id'] == widget.id.toString()) {
        item['quantity'] = (item['quantity'] as int) + 1;
        found = true;
        break;
      }
    }
    if (!found) {
      DummyData.cartItems.add({
        'product_id': widget.id.toString(),
        'name': widget.name,
        'price': widget.price,
        'quantity': 1,
        'imageUrl': _assetImage,
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void toggleWishlist() {
    setState(() => isFavorite = !isFavorite);
    if (isFavorite) {
      bool exists = DummyData.wishlistItems.any((item) => item['product_id'] == widget.id.toString());
      if (!exists) {
        DummyData.wishlistItems.add({
          'user_id': DummyData.demoUserId,
          'product_id': widget.id.toString(),
          'name': widget.name,
          'price': widget.price,
          'imageUrl': _assetImage,
        });
      }
    } else {
      DummyData.wishlistItems.removeWhere((item) => item['product_id'] == widget.id.toString());
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
                    child: Image.asset(_assetImage, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: toggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: isFavorite ? Colors.red : Colors.grey),
                    ),
                  ),
                ),
                if (int.parse(widget.stock) < 30)
                  Positioned(
                    top: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.shade600, borderRadius: BorderRadius.circular(6)),
                      child: Text('Low Stock', style: GoogleFonts.rubik(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\u20B9${widget.price}', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                      GestureDetector(
                        onTap: addToCart,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFF019934), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
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
