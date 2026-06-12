import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/wishlist/domain/wishlist_controller.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final _wishlist = Get.put(WishlistController());

  @override
  void initState() {
    super.initState();
    _wishlist.loadWishlist();
  }

  Future<void> _addToCart(String productId) async {
    final cart = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final success = await cart.addProduct(productId);
    if (!mounted) return;
    if (success) {
      showApiSnackBar(context, 'Added to cart');
    } else {
      showApiSnackBar(
        context,
        cart.errorMessage.value.isNotEmpty
            ? cart.errorMessage.value
            : 'Could not add to cart',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Wishlist', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
      ),
      body: Obx(() {
        if (_wishlist.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF019934)));
        }
        if (_wishlist.errorMessage.value.isNotEmpty && _wishlist.items.isEmpty) {
          return ApiStateView(status: ApiViewStatus.error, errorMessage: _wishlist.errorMessage.value, onRetry: _wishlist.loadWishlist, child: const SizedBox());
        }
        if (_wishlist.items.isEmpty) {
          return ApiStateView(status: ApiViewStatus.empty, emptyMessage: 'Your wishlist is empty', child: const SizedBox());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _wishlist.items.length,
          itemBuilder: (context, index) {
            final item = _wishlist.items[index];
            final productId = item['product_id']?.toString() ?? item['pd_id']?.toString() ?? '';
            return Card(
              child: ListTile(
                title: Text(item['name']?.toString() ?? item['product_name']?.toString() ?? ''),
                subtitle: Text('₹${item['price']?.toString() ?? '0'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => _addToCart(productId)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _wishlist.toggle(productId, add: false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
