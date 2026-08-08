import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../../viewmodels/wishlist_view_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_states.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistViewModel>();
    final cart = context.read<CartViewModel>();
    final shell = context.read<ShellController>();

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Wishlist', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: wishlist.isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.green),
              ),
            )
          : wishlist.products.isEmpty
              ? EmptyState(
                  title: 'No saved products',
                  subtitle: 'Tap the heart on a product to save it here for later.',
                  icon: Icons.favorite_border_rounded,
                  ctaLabel: 'Browse Catalog',
                  onCta: () {
                    Navigator.of(context).pop();
                    shell.goToCategories();
                  },
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: wishlist.products.length,
                  itemBuilder: (context, index) {
                    final product = wishlist.products[index];
                    return Column(
                      children: [
                        Expanded(
                          child: ProductCard(
                            product: product,
                            onTap: () => AppPageRoute.push(
                              context,
                              ProductDetailScreen(productId: product.id),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: PressableScale(
                                onTap: () {
                                  cart.addProduct(product, quantity: product.moq);
                                  showAppSuccessSnackBar(
                                    context,
                                    message: 'Moved to cart',
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.green,
                                    borderRadius: BorderRadius.circular(AppRadii.pill),
                                  ),
                                  child: Text(
                                    'To Cart',
                                    style: AppTextStyles.body(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            PressableScale(
                              onTap: () => wishlist.remove(product.id),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.alert,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate(delay: (index * 40).ms).fadeIn(duration: 220.ms);
                  },
                ),
    );
  }
}
