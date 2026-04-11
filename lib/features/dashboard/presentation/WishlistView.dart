import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';

class WishListPage extends StatefulWidget {
  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  void _loadWishlistItems() {
    setState(() {
      wishlistItems = List<Map<String, dynamic>>.from(DummyData.wishlistItems.map((item) => Map<String, dynamic>.from(item)));
      isLoading = false;
    });
  }

  void deleteWishlistItem(int index) {
    setState(() => wishlistItems.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Removed from wishlist'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void moveToCart() {
    for (var item in wishlistItems) {
      bool found = false;
      for (var cartItem in DummyData.cartItems) {
        if (cartItem['product_id'] == item['product_id']) {
          cartItem['quantity'] = (cartItem['quantity'] as int) + 1;
          found = true;
          break;
        }
      }
      if (!found) {
        DummyData.cartItems.add({
          'product_id': item['product_id'],
          'name': item['name'],
          'price': item['price'],
          'quantity': 1,
          'imageUrl': item['imageUrl'] ?? DummyData.getProductImage(item['product_id']),
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('All items moved to cart!'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xFF019934),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Wishlist', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF019934)))
          : wishlistItems.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Your wishlist is empty', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text('Save items you love here', style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade400)),
                  ]),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: wishlistItems.length,
                        itemBuilder: (context, index) {
                          final item = wishlistItems[index];
                          final imageUrl = item['imageUrl'] ?? DummyData.getProductImage(item['product_id']);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(item['name'], style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('\u20B9${item['price']}', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                                    ]),
                                  ),
                                  IconButton(
                                    onPressed: () => deleteWishlistItem(index),
                                    icon: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF019934),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: moveToCart,
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          label: Text('Move All to Cart', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
