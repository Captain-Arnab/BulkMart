import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  final _products = Get.put(ProductsController());

  List<Product> _results = [];
  ApiViewStatus _status = ApiViewStatus.idle;
  String? _error;

  String? _category;
  double? _minPrice;
  double? _maxPrice;
  bool? _inStock;
  String? _sort;
  int _page = 1;
  static const _limit = 20;

  static const _sortOptions = <String, String>{
    'relevance': 'Relevance',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'newest': 'Newest',
    'name_asc': 'Name A–Z',
  };

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search({bool resetPage = true}) async {
    final keyword = _query.text.trim();
    if (keyword.isEmpty &&
        (_category == null || _category!.isEmpty) &&
        _minPrice == null &&
        _maxPrice == null &&
        _inStock == null) {
      return;
    }

    if (resetPage) _page = 1;
    setState(() {
      _status = ApiViewStatus.loading;
      _error = null;
    });

    try {
      final results = await _products.searchProducts(
        keyword: keyword,
        category: _category,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        inStock: _inStock,
        sort: _sort,
        page: _page,
        limit: _limit,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _status =
            results.isEmpty ? ApiViewStatus.empty : ApiViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = ApiViewStatus.error;
        _error = _products.errorMessage.value.isNotEmpty
            ? _products.errorMessage.value
            : e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openFilters() async {
    final categories = _products.categories;
    if (categories.isEmpty) {
      await _products.fetchCategories();
    }

    if (!mounted) return;
    final applied = await showModalBottomSheet<_SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchFilterSheet(
        initial: _SearchFilters(
          category: _category,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          inStock: _inStock,
          sort: _sort,
        ),
        categories: _products.categories
            .map((c) => MapEntry(c.id, c.name))
            .toList(),
        sortOptions: _sortOptions,
      ),
    );

    if (applied == null || !mounted) return;
    setState(() {
      _category = applied.category;
      _minPrice = applied.minPrice;
      _maxPrice = applied.maxPrice;
      _inStock = applied.inStock;
      _sort = applied.sort;
    });
    await _search();
  }

  bool get _hasActiveFilters =>
      (_category != null && _category!.isNotEmpty) ||
      _minPrice != null ||
      _maxPrice != null ||
      _inStock == true ||
      (_sort != null && _sort!.isNotEmpty && _sort != 'relevance');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _query,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _hasActiveFilters,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _search,
        emptyMessage: 'No products match your search',
        child: _status == ApiViewStatus.idle
            ? Center(
                child: Text(
                  'Search by name or apply filters',
                  style: GoogleFonts.rubik(color: Colors.grey.shade600),
                ),
              )
            : GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _results.length,
          itemBuilder: (context, i) {
            final p = _results[i];
            return ProductCard(
              id: int.tryParse(p.id) ?? 0,
              productId: p.id,
              name: p.name,
              grams: p.grams,
              stock: p.stock,
              price: p.price,
              imageUrl: p.imageUrl,
              onProductTap: () => openProductDetails(context, p),
            );
          },
        ),
      ),
    );
  }
}

class _SearchFilters {
  const _SearchFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.inStock,
    this.sort,
  });

  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStock;
  final String? sort;
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({
    required this.initial,
    required this.categories,
    required this.sortOptions,
  });

  final _SearchFilters initial;
  final List<MapEntry<String, String>> categories;
  final Map<String, String> sortOptions;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late String? _category = widget.initial.category;
  late RangeValues _price = RangeValues(
    widget.initial.minPrice ?? 0,
    widget.initial.maxPrice ?? 2000,
  );
  late bool _inStock = widget.initial.inStock == true;
  late String _sort = widget.initial.sort ?? 'relevance';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filters',
              style: GoogleFonts.rubik(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All categories'),
                ),
                ...widget.categories.map(
                  (e) => DropdownMenuItem<String?>(
                    value: e.key,
                    child: Text(e.value),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: ₹${_price.start.round()} – ₹${_price.end.round()}',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _price,
              min: 0,
              max: 2000,
              divisions: 40,
              activeColor: AppColors.primary,
              labels: RangeLabels(
                '₹${_price.start.round()}',
                '₹${_price.end.round()}',
              ),
              onChanged: (v) => setState(() => _price = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'In stock only',
                style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
              ),
              value: _inStock,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _inStock = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Sort by',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _sort,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.sortOptions.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _sort = v);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        const _SearchFilters(sort: 'relevance'),
                      );
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _SearchFilters(
                          category: _category,
                          minPrice: _price.start <= 0 ? null : _price.start,
                          maxPrice: _price.end >= 2000 ? null : _price.end,
                          inStock: _inStock ? true : null,
                          sort: _sort == 'relevance' ? null : _sort,
                        ),
                      );
                    },
                    child: Text(
                      'Apply',
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
