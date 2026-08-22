import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/offer_style.dart';
import '../../../models/product.dart';
import '../../../models/user.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../../viewmodels/notification_view_model.dart';
import '../../../viewmodels/offer_view_model.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/location_picker_sheet.dart';
import '../../widgets/product_card.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/ui_states.dart';
import '../notifications/notifications_screen.dart';
import '../offers/offers_screen.dart';
import '../product/product_detail_screen.dart';
import '../wishlist/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
      context.read<OfferViewModel>().load();
      context.read<NotificationViewModel>().load();
    });
  }

  /// Routes catalog entry points through the Products tab (not a stack push).
  void _openBrowse({String? categoryId, String? query}) {
    context.read<ShellController>().goToCategories(
          categoryId: categoryId ?? 'all',
          query: query,
        );
  }

  void _openSaved() {
    AppPageRoute.push(context, const WishlistScreen());
  }

  void _openAlerts() {
    AppPageRoute.push(context, const NotificationsScreen());
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final user = context.select<AuthViewModel, User?>((a) => a.user);
    final deliveryLabel = context.select<AddressViewModel, String>((a) {
      final delivery = a.defaultAddress;
      return delivery == null
          ? 'Add delivery address'
          : '${delivery.label} · ${delivery.city}';
    });
    final shell = context.read<ShellController>();
    final categories = home.categories.where((c) => c.id != 'all').toList();
    final unread = context.select<NotificationViewModel, int>((n) => n.unreadCount);

    return Scaffold(
      backgroundColor: AppColors.section,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar — location + actions + profile
            Material(
              color: AppColors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: AppShadows.soft(opacity: 0.04),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => showLocationPickerSheet(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                    ),
                    _HomeTopAction(
                      icon: Icons.grid_view_rounded,
                      label: 'Products',
                      onTap: () => _openBrowse(),
                    ),
                    _HomeTopAction(
                      icon: Icons.favorite_border_rounded,
                      label: 'Saved',
                      onTap: _openSaved,
                    ),
                    _HomeTopAction(
                      icon: Icons.notifications_none_rounded,
                      label: 'Alerts',
                      badgeCount: unread,
                      onTap: _openAlerts,
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: shell.goToAccount,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ProfileAvatar(user: user, size: 36),
                      ),
                    ),
                  ],
                ),
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
                                'Search fruits & vegetables…',
                                style: AppTextStyles.body(fontSize: 14, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 180.ms),
                    const SizedBox(height: 16),

                    // Banner carousel (isolated so auto-play doesn't rebuild Home)
                    const _HomeBannerCarousel(),
                    const SizedBox(height: 18),

                    // Category chips
                    if (categories.isNotEmpty)
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return PressableScale(
                              onTap: () => _openBrowse(categoryId: cat.id),
                              child: SizedBox(
                                width: 68,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.line),
                                        boxShadow: AppShadows.card,
                                      ),
                                      child: CategoryIcon(
                                        categoryId: cat.id,
                                        size: 26,
                                        color: AppColors.green,
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

                    // Category-wise horizontal sections
                    if (home.error != null && home.products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 32),
                        child: ErrorState(
                          message: home.error!,
                          onRetry: () => home.refresh(),
                        ),
                      )
                    else if (home.isLoading && home.products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._buildCategorySections(home),

                    // Browse entry — last on Home so discovery rows come first
                    const SizedBox(height: 8),
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
                                  color: AppColors.greenSoft,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.green,
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
                                      '${home.products.isEmpty ? '33' : home.products.length} produce items · bulk wholesale',
                                      style: AppTextStyles.body(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.green),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections(HomeViewModel home) {
    final widgets = <Widget>[];
    var sectionIndex = 0;

    for (final categoryId in home.homeSectionCategoryIds) {
      final items = home.productsForCategory(categoryId, limit: 8);
      if (items.isEmpty) continue;

      final title = home.categoryById(categoryId)?.name ??
          switch (categoryId) {
            '1' || 'green_vegetables' => 'Green Vegetables',
            '2' || 'root_vegetables' => 'Root Vegetables',
            '3' || 'seasonal_fruits' => 'Seasonal Fruits',
            '4' || 'herbs_leafy' => 'Herbs & Leafy',
            _ => categoryId,
          };

      widgets.add(
        _CategoryProductSection(
          title: title,
          products: items,
          onSeeAll: () => _openBrowse(categoryId: categoryId),
          onProductTap: (product) {
            AppPageRoute.push(
              context,
              ProductDetailScreen(productId: product.id),
            );
          },
        )
            .animate(delay: (sectionIndex * 90).ms)
            .fadeIn(duration: 320.ms, curve: Curves.easeOut)
            .slideY(begin: 0.06, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
      );
      sectionIndex++;
    }

    return widgets;
  }
}

class _CategoryProductSection extends StatelessWidget {
  const _CategoryProductSection({
    required this.title,
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
  });

  final String title;
  final List<Product> products;
  final VoidCallback onSeeAll;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.display(fontSize: 18),
                ),
              ),
              PressableScale(
                onTap: onSeeAll,
                child: Text(
                  'See All →',
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
        Builder(
          builder: (context) {
            final screenW = MediaQuery.sizeOf(context).width;
            // ~3.4 cards in the initial viewport (glimpse, not a catalog).
            final cardW = (screenW / 3.4).clamp(100.0, 132.0);
            // Compact ratio: square-ish image + fixed text block (~1.38 overall).
            final cardH = cardW * 1.38;
            return SizedBox(
              height: cardH,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 28, 0),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: cardW,
                    child: ProductCard(
                      product: product,
                      onTap: () => onProductTap(product),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HomeTopAction extends StatelessWidget {
  const _HomeTopAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: AppColors.violet, size: 22),
                    if (badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -5,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          height: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.alert,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            style: AppTextStyles.body(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
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
      ),
    );
  }
}

class _HomeBannerCarousel extends StatefulWidget {
  const _HomeBannerCarousel();

  @override
  State<_HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<_HomeBannerCarousel> {
  int _bannerIndex = 0;

  void _openOffers() {
    AppPageRoute.push(context, const OffersScreen());
  }

  @override
  Widget build(BuildContext context) {
    final featured = context.watch<OfferViewModel>().featured;
    if (featured.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: _ViewAllOffersLink(onTap: _openOffers),
        ),
      );
    }

    return Column(
      children: [
        // Clip so enlargeCenterPage overflow can't steal taps from the link below.
        ClipRect(
          child: CarouselSlider.builder(
            itemCount: featured.length,
            itemBuilder: (context, index, _) {
              final offer = featured[index];
              final colors = OfferStyle.colorsOf(offer);
              final textColor = OfferStyle.textColorOf(offer);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  onTap: _openOffers,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offer.title,
                      style: AppTextStyles.display(
                        fontSize: 18,
                        color: textColor,
                        height: 1.25,
                      ),
                    ),
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
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(featured.length, (i) {
                    final active = i == _bannerIndex;
                    return AnimatedContainer(
                      duration: AppMotion.fast,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 18 : 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.green : AppColors.line,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    );
                  }),
                ),
              ),
              _ViewAllOffersLink(onTap: _openOffers),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewAllOffersLink extends StatelessWidget {
  const _ViewAllOffersLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'View all offers →',
            style: AppTextStyles.body(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
            ),
          ),
        ),
      ),
    );
  }
}
