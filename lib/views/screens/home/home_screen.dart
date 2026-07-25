import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final home = context.watch<HomeViewModel>();
    final business = (auth.user?.businessName ?? 'Bulk buyer').toUpperCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.forest,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 10,
                left: 18,
                right: 18,
                bottom: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business,
                    style: AppTextStyles.mono(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "What's stocking up today?",
                    style: AppTextStyles.display(fontSize: 18, color: AppColors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: home.onSearchChanged,
                style: AppTextStyles.body(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search rice, oil, spices…',
                  prefixIcon: const Icon(Icons.search, color: AppColors.slate, size: 20),
                  filled: true,
                  fillColor: AppColors.paper,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.forest, width: 1.4),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: home.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = home.categories[index];
                  final selected = home.selectedCategoryId == cat.id;
                  return FilterChip(
                    label: Text(cat.name),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => home.selectCategory(cat.id),
                    selectedColor: AppColors.forest,
                    backgroundColor: AppColors.paper2,
                    labelStyle: AppTextStyles.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.ink,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
        subtitle: 'Try another category or search term.',
      );
    }

    return RefreshIndicator(
      color: AppColors.forest,
      onRefresh: home.refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: home.products.length + (home.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= home.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.forest),
              ),
            );
          }
          final product = home.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: product.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
