import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_states.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;
  String _animKey = 'init';

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      context.read<HomeViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _syncAnimKey(HomeViewModel home) {
    final next =
        '${home.selectedCategoryId}|${home.searchQuery}|${home.products.map((e) => e.id).join(',')}';
    if (next != _animKey && !home.isLoadingMore) {
      _animKey = next;
    }
  }

  IconData _categoryIcon(String id) {
    switch (id) {
      case 'grains':
        return Icons.rice_bowl_rounded;
      case 'oil':
        return Icons.water_drop_rounded;
      case 'dal':
        return Icons.grain_rounded;
      case 'spices':
        return Icons.spa_rounded;
      case 'dry_fruits':
        return Icons.eco_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final home = context.watch<HomeViewModel>();
    _syncAnimKey(home);
    final business = auth.user?.businessName ?? 'Bulk buyer';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.section,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7B2FF7),
                    Color(0xFF9B5CFF),
                    Color(0xFF5B1FD6),
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.toUpperCase(),
                    style: AppTextStyles.label(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock up today ⚡',
                    style: AppTextStyles.display(fontSize: 24, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  AnimatedScale(
                    scale: _searchFocused ? 1.02 : 1,
                    duration: AppMotion.press,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: home.onSearchChanged,
                      style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search rice, oil, spices…',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          borderSide: const BorderSide(color: AppColors.accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                scrollDirection: Axis.horizontal,
                itemCount: home.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final cat = home.categories[index];
                  final selected = home.selectedCategoryId == cat.id;
                  return PressableScale(
                    onTap: () => home.selectCategory(cat.id),
                    child: SizedBox(
                      width: 68,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: AppMotion.fast,
                            curve: AppMotion.pop,
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.violet.withValues(alpha: 0.12)
                                  : AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? AppColors.violet : AppColors.line,
                                width: selected ? 2.5 : 1,
                              ),
                              boxShadow: selected
                                  ? AppShadows.soft(color: AppColors.violet, opacity: 0.2)
                                  : AppShadows.card,
                            ),
                            child: Icon(
                              _categoryIcon(cat.id),
                              color: selected ? AppColors.violet : AppColors.muted,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedDefaultTextStyle(
                            duration: AppMotion.fast,
                            style: AppTextStyles.body(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.violet : AppColors.muted,
                            ),
                            child: Text(
                              cat.name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: _buildBody(home)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HomeViewModel home) {
    if (home.isLoading && home.products.isEmpty) {
      return const CatalogShimmer();
    }
    if (home.error != null && home.products.isEmpty) {
      return ErrorState(message: home.error!, onRetry: home.refresh);
    }
    if (home.products.isEmpty) {
      return const EmptyState(
        title: 'No products found',
        subtitle: 'Try a different search term or category.',
        lottieAsset: 'assets/lottie/empty_cart.json',
        icon: Icons.search_off_rounded,
      );
    }

    return RefreshIndicator(
      color: AppColors.violet,
      backgroundColor: AppColors.white,
      onRefresh: home.refresh,
      child: AnimationLimiter(
        key: ValueKey(_animKey),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 160),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: home.products.length + (home.isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= home.products.length) {
              return const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.violet,
                  ),
                ),
              );
            }
            final product = home.products[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 220),
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 20,
                curve: AppMotion.ease,
                child: FadeInAnimation(
                  child: ProductCard(
                    product: product,
                    onTap: () {
                      AppPageRoute.push(
                        context,
                        ProductDetailScreen(productId: product.id),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
