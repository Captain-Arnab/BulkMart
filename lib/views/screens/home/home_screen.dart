import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/location_picker_sheet.dart';
import '../../widgets/product_card.dart';
import '../../widgets/profile_avatar.dart';
import '../catalog/category_browse_screen.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;

  static const _banners = [
    _BannerData(
      title: 'Flat 10% off on bulk\norders above ₹10,000',
      colors: [Color(0xFF7B2FF7), Color(0xFF9B4DFF)],
    ),
    _BannerData(
      title: 'New: Cashew & Dry Fruits\nnow available',
      colors: [Color(0xFFFFC93C), Color(0xFFFFB347)],
      textColor: AppColors.ink,
    ),
    _BannerData(
      title: 'Free delivery\nthis week',
      colors: [Color(0xFF0FA968), Color(0xFF14C47A)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  void _openBrowse({String? categoryId, String? query}) {
    AppPageRoute.push(
      context,
      CategoryBrowseScreen(
        initialCategoryId: categoryId,
        initialQuery: query,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final auth = context.watch<AuthViewModel>();
    final addressVm = context.watch<AddressViewModel>();
    final shell = context.read<ShellController>();
    final delivery = addressVm.defaultAddress;
    final deliveryLabel = delivery == null
        ? 'Add delivery address'
        : '${delivery.label} · ${delivery.city}';

    return Scaffold(
      backgroundColor: AppColors.section,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar — location + profile + Products shortcut
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: AppShadows.soft(opacity: 0.04),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () => showLocationPickerSheet(context),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.violet, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivering to',
                                  style: AppTextStyles.body(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        deliveryLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.body(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PressableScale(
                    onTap: () => _openBrowse(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.grid_view_rounded, color: AppColors.violet, size: 20),
                          Text(
                            'Products',
                            style: AppTextStyles.body(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.violet,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PressableScale(
                    onTap: () => shell.goToTab(3),
                    child: ProfileAvatar(user: auth.user, size: 36),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.violet,
                onRefresh: home.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 140),
                  children: [
                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PressableScale(
                        onTap: () => _openBrowse(),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(color: AppColors.line),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.muted),
                              const SizedBox(width: 10),
                              Text(
                                'Search for rice, oil, spices…',
                                style: AppTextStyles.body(fontSize: 14, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.08, end: 0),
                    const SizedBox(height: 16),

                    // Banner carousel
                    CarouselSlider.builder(
                      itemCount: _banners.length,
                      itemBuilder: (context, index, _) {
                        final b = _banners[index];
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            gradient: LinearGradient(
                              colors: b.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            b.title,
                            style: AppTextStyles.display(
                              fontSize: 18,
                              color: b.textColor,
                              height: 1.25,
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 120,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                        onPageChanged: (i, _) => setState(() => _bannerIndex = i),
                      ),
                    ).animate().fadeIn(delay: 60.ms, duration: 220.ms),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_banners.length, (i) {
                        final active = i == _bannerIndex;
                        return AnimatedContainer(
                          duration: AppMotion.fast,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: active ? 18 : 6,
                          decoration: BoxDecoration(
                            color: active ? AppColors.violet : AppColors.line,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Browse entry card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PressableScale(
                        onTap: () => _openBrowse(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EBFF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.violet,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Browse All Products',
                                      style: AppTextStyles.body(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '500+ items across 12 categories',
                                      style: AppTextStyles.body(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.violet),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 220.ms),
                    const SizedBox(height: 16),

                    // Category chips
                    if (home.categories.isNotEmpty)
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: home.categories.where((c) => c.id != 'all').length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cats = home.categories.where((c) => c.id != 'all').toList();
                            final cat = cats[index];
                            return PressableScale(
                              onTap: () => _openBrowse(categoryId: cat.id),
                              child: SizedBox(
                                width: 68,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.line),
                                        boxShadow: AppShadows.card,
                                      ),
                                      child: Icon(
                                        categoryIconFor(cat.id),
                                        color: AppColors.violet,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      categoryShortLabel(cat),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Popular in Bulk
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Row(
                        children: [
                          Text(
                            'Popular in Bulk',
                            style: AppTextStyles.display(fontSize: 18),
                          ),
                          const Spacer(),
                          PressableScale(
                            onTap: () => _openBrowse(),
                            child: Text(
                              'See All',
                              style: AppTextStyles.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.violet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 240,
                      child: home.products.isEmpty
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.violet,
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: home.products.take(5).length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final product = home.products[index];
                                return SizedBox(
                                  width: 160,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () {
                                      AppPageRoute.push(
                                        context,
                                        ProductDetailScreen(productId: product.id),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.colors,
    this.textColor = AppColors.white,
  });

  final String title;
  final List<Color> colors;
  final Color textColor;
}
