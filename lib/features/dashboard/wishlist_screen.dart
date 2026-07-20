import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/wishlist/wishlist_controller.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final _wishlist = WishlistController.findOrPut();

  @override
  void initState() {
    super.initState();
    _wishlist.loadWishlist();
  }

  Future<void> _addToCart(String productId) async {
    final cart = CartController.findOrPut();
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
      backgroundColor: AppColors.scaffold,
      appBar: const ModernAppBar(title: 'My Wishlist'),
      body: Obx(() {
        if (_wishlist.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (_wishlist.errorMessage.value.isNotEmpty &&
            _wishlist.items.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: _wishlist.errorMessage.value,
            onRetry: _wishlist.loadWishlist,
            child: const SizedBox(),
          );
        }
        if (_wishlist.items.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.empty,
            emptyMessage: 'Your wishlist is empty',
            child: const SizedBox(),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _wishlist.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _wishlist.items[index];
            final productId = item['product_id']?.toString() ??
                item['pd_id']?.toString() ??
                '';
            final name = item['name']?.toString() ??
                item['product_name']?.toString() ??
                '';
            final price = item['price']?.toString() ?? '0';
            final imageUrl = pickImageUrl(item);

            return ModernListTile(
              title: name,
              subtitle: '₹$price',
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NetworkOrAssetImage(
                  url: imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: AppColors.primary,
                    onPressed: () => _addToCart(productId),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                    onPressed: () => _wishlist.toggle(productId, add: false),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
