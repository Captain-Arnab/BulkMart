import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/AppSearchBarWidget.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/home/home_view_model.dart';
import 'package:urban_roots/features/home/models/home_models.dart';
import 'package:urban_roots/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:urban_roots/features/home/presentation/widgets/home_categories_grid.dart';
import 'package:urban_roots/features/home/presentation/widgets/home_featured_grid.dart';
import 'package:urban_roots/features/home/presentation/widgets/home_horizontal_product_row.dart';
import 'package:urban_roots/features/home/presentation/widgets/home_offers_row.dart';
import 'package:urban_roots/features/notifications/notifications_controller.dart';
import 'package:urban_roots/features/wishlist/wishlist_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _vm;
  final _notificationsController = NotificationsController.findOrPut();

  @override
  void initState() {
    super.initState();
    _vm = HomeViewModel();
    _vm.addListener(_onVmChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Don't block first home paint on cart / notifications / wishlist.
    unawaited(_notificationsController.refreshUnreadCount());
    unawaited(CartController.findOrPut().loadCart());
    unawaited(WishlistController.findOrPut().syncMembershipFromServer());
    await _vm.load();
  }

  void _onVmChanged() => setState(() {});

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const AppSearchBarWidget(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _bootstrap,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final state = _vm.state;

    if (state is UiLoading<HomeUiData>) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      );
    }

    if (state is UiError<HomeUiData>) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _vm.load,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    final data = (state as UiSuccess<HomeUiData>).data;
    final children = <Widget>[
      const Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: HomeBannerCarousel(),
      ),
    ];

    if (data.locationFilterActive) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Material(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.near_me_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.locationLabel.isNotEmpty
                          ? 'Showing products near ${data.locationLabel}'
                          : 'Showing products near you',
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _vm.clearLocationFilter,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Show all',
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (data.categories.isNotEmpty) {
      children.add(HomeCategoriesGrid(categories: data.categories));
    }

    if (data.offers.isNotEmpty) {
      children.add(HomeOffersRow(offers: data.offers));
    }

    if (data.featuredProducts.isNotEmpty) {
      children.add(
        HomeFeaturedGrid(
          products: data.featuredProducts,
          onViewAll: () => DashboardController.findOrPut().goToTab(1),
        ),
      );
    }

    for (final section in data.categorySections) {
      children.add(
        HomeHorizontalProductRow(
          sectionTitle: section.category.name,
          products: section.products,
          categoryId: section.category.id,
          categoryName: section.category.name,
          showSeeAll: true,
        ),
      );
    }

    if (data.sectionsLoading) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (data.featuredProducts.isEmpty &&
        data.categorySections.isEmpty &&
        data.categories.isEmpty &&
        !data.sectionsLoading) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No products available right now',
              style: GoogleFonts.rubik(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 24));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }
}
