import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/category_browse_view_model.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_states.dart';
import '../product/product_detail_screen.dart';

class CategoryBrowseScreen extends StatefulWidget {
  const CategoryBrowseScreen({
    super.key,
    this.initialCategoryId,
    this.initialQuery,
    this.asTab = false,
  });

  final String? initialCategoryId;
  final String? initialQuery;

  /// When true, used as MainShell tab content (no back button; listens for shell intents).
  final bool asTab;

  @override
  State<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends State<CategoryBrowseScreen> {
  late final CategoryBrowseViewModel _vm;
  late final TextEditingController _search;
  ShellController? _shell;
  int _lastIntentSeq = 0;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery ?? '');
    _vm = CategoryBrowseViewModel(
      productRepository: context.read<ProductRepository>(),
    );
    _vm.init(
      categoryId: widget.initialCategoryId,
      query: widget.initialQuery,
    );
    if (widget.asTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _shell = context.read<ShellController>();
        _shell!.addListener(_onShellChanged);
        _applyPendingIntent();
      });
    }
  }

  @override
  void dispose() {
    _shell?.removeListener(_onShellChanged);
    _search.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _onShellChanged() {
    if (!mounted || _shell == null) return;
    if (_shell!.tabIndex != ShellController.categoriesTab) return;
    _applyPendingIntent();
  }

  void _applyPendingIntent() {
    final shell = _shell;
    if (shell == null) return;
    if (shell.categoriesIntentSeq == _lastIntentSeq) return;
    _lastIntentSeq = shell.categoriesIntentSeq;
    final cat = shell.pendingCategoryId;
    final q = shell.pendingBrowseQuery;
    shell.clearCategoriesIntent();
    if (cat == null && q == null) return;
    if (q != null && _search.text != q) {
      _search.text = q;
    }
    _vm.applyBrowseIntent(categoryId: cat, query: q);
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: _vm,
        child: const _FilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use viewPadding once — Material AppBar + edge-to-edge can stack insets
    // and leave a large empty band above the title.
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return ChangeNotifierProvider.value(
      value: _vm,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.section,
          body: Column(
            children: [
              Material(
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        if (widget.asTab)
                          const SizedBox(width: 16)
                        else ...[
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppColors.ink,
                          ),
                        ],
                        Text(
                          'Products',
                          style: AppTextStyles.display(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<CategoryBrowseViewModel>(
                  builder: (context, vm, _) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CategorySidebar(
                          categories: vm.categories,
                          selectedId: vm.selectedCategoryId,
                          onSelect: vm.selectCategory,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                color: AppColors.white,
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: PillTextField(
                                        controller: _search,
                                        hint: 'Search products…',
                                        prefix: const Padding(
                                          padding: EdgeInsets.only(left: 14),
                                          child: Icon(
                                            Icons.search_rounded,
                                            color: AppColors.muted,
                                            size: 20,
                                          ),
                                        ),
                                        onChanged: vm.onSearchChanged,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PressableScale(
                                      onTap: _openFilters,
                                      child: Container(
                                        height: 52,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.section,
                                          borderRadius: BorderRadius.circular(AppRadii.pill),
                                          border: Border.all(color: AppColors.line),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.tune_rounded,
                                              size: 18,
                                              color: AppColors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Filters',
                                              style: AppTextStyles.body(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (vm.activeFilterCount > 0) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.green,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${vm.activeFilterCount}',
                                                  style: AppTextStyles.price(
                                                    fontSize: 10,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: _ProductPane(vm: vm)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  const _CategorySidebar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ProductCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      color: AppColors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat.id == selectedId;
          return PressableScale(
            onTap: () => onSelect(cat.id),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.greenSoft : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: selected ? AppColors.violet : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CategoryCircleImage(
                    category: cat,
                    size: 40,
                    iconSize: 22,
                    fallbackColor:
                        selected ? AppColors.violet : AppColors.muted,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoryShortLabel(cat),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? AppColors.violet : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductPane extends StatelessWidget {
  const _ProductPane({required this.vm});

  final CategoryBrowseViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.products.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.violet),
        ),
      );
    }
    if (vm.error != null && vm.products.isEmpty) {
      return ErrorState(message: vm.error!, onRetry: vm.refresh);
    }
    if (vm.products.isEmpty) {
      return const EmptyState(
        title: 'No products found',
        subtitle: 'Try another category or clear filters.',
        icon: Icons.inventory_2_outlined,
      );
    }

    // Pane width ≈ screen − sidebar(96). Aim for short cards: image-forward + compact text.
    final paneW = MediaQuery.sizeOf(context).width - 96;
    final cellW = (paneW - 10 * 2 - 10) / 2; // padding + gap
    final cellH = cellW * 1.05 + 68; // near-square image + text block
    final aspect = cellW / cellH;

    return AnimatedSwitcher(
      duration: AppMotion.normal,
      child: GridView.builder(
        key: ValueKey('${vm.selectedCategoryId}_${vm.searchQuery}_${vm.activeFilterCount}_${vm.sort}'),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: aspect.clamp(0.68, 0.82),
        ),
        itemCount: vm.products.length,
        itemBuilder: (context, index) {
          final product = vm.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              AppPageRoute.push(
                context,
                ProductDetailScreen(productId: product.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _price;
  late bool _stockOnly;
  late BrowseSort _sort;

  @override
  void initState() {
    super.initState();
    final vm = context.read<CategoryBrowseViewModel>();
    _price = RangeValues(vm.filterMinPrice, vm.filterMaxPrice);
    _stockOnly = vm.inStockOnly;
    _sort = vm.sort;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoryBrowseViewModel>();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filters', style: AppTextStyles.display(fontSize: 20)),
          const SizedBox(height: 16),
          Text('Price range', style: AppTextStyles.body(fontWeight: FontWeight.w700)),
          RangeSlider(
            values: _price,
            min: vm.minPrice,
            max: vm.maxPrice,
            divisions: 20,
            activeColor: AppColors.violet,
            labels: RangeLabels(
              '₹${_price.start.round()}',
              '₹${_price.end.round()}',
            ),
            onChanged: (v) => setState(() => _price = v),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'In stock only',
                  style: AppTextStyles.body(fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: _stockOnly,
                activeColor: AppColors.violet,
                onChanged: (v) => setState(() => _stockOnly = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Sort by', style: AppTextStyles.body(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('Popularity', BrowseSort.popularity),
              _sortChip('Price: Low–High', BrowseSort.priceLowHigh),
              _sortChip('Price: High–Low', BrowseSort.priceHighLow),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () {
                    vm.resetFilters();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      'Reset',
                      style: AppTextStyles.body(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PressableScale(
                  onTap: () {
                    vm.applyFilters(
                      min: _price.start,
                      max: _price.end,
                      stockOnly: _stockOnly,
                      sortBy: _sort,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: AppShadows.button(),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyles.body(
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.12, end: 0, duration: 320.ms, curve: Curves.easeOutBack);
  }

  Widget _sortChip(String label, BrowseSort value) {
    final selected = _sort == value;
    return PressableScale(
      onTap: () => setState(() => _sort = value),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet : AppColors.section,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
