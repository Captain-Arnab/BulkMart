import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/data/repositories/home_repository.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:get/get.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';
import 'package:urban_roots/features/products/presentation/filterScreen.dart';
import 'package:urban_roots/features/products/presentation/widgets/applied_filters_bar.dart';
import 'package:urban_roots/features/products/presentation/widgets/category_sidebar.dart';
import 'package:urban_roots/features/products/presentation/widgets/product_filter_sort_bar.dart';
import 'package:urban_roots/features/products/utils/product_list_filters.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _repository = ApiHomeRepository();
  final _productsController = Get.put(ProductsController());
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<Category> _categories = [];
  late String _selectedCategoryId;
  late String _selectedCategoryName;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoadingCategories = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 1;
  static const _pageSize = 20;
  static const double _sidebarWidth = 78;
  ProductSortOption _sortOption = ProductSortOption.relevance;

  double _minPrice = 0;
  double _maxPrice = ActiveProductFilters.defaultMaxPrice;
  int? _minGrams;
  int? _maxGrams;
  String? _packingType;
  int? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedCategoryName = widget.categoryName;
    CartController.findOrPut().loadCart();
    _loadCategories();
    _loadPage(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  void _selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    Category? cat;
    for (final c in _categories) {
      if (c.id == categoryId) {
        cat = c;
        break;
      }
    }
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = cat?.name ?? _selectedCategoryName;
      _filterCategoryId = null;
    });
    _loadPage(reset: true);
  }

  List<String> get _packingTypesList {
    if (_packingType == null || _packingType!.trim().isEmpty) return const [];
    return _packingType!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  FilterScreenInitial get _filterInitial => FilterScreenInitial(
        categoryId: _filterCategoryId ?? int.tryParse(_selectedCategoryId) ?? 0,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minGrams: _minGrams,
        maxGrams: _maxGrams,
        packingTypes: _packingTypesList,
      );

  ActiveProductFilters get _activeFilters => ActiveProductFilters(
        categoryName: _filterCategoryName,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minGrams: _minGrams,
        maxGrams: _maxGrams,
        packingTypes: _packingTypesList,
        sort: _sortOption,
      );

  String? get _filterCategoryName {
    if (_filterCategoryId == null || _filterCategoryId == 0) return null;
    for (final cat in _categories) {
      if (int.tryParse(cat.id) == _filterCategoryId) return cat.name;
    }
    return null;
  }

  void _clearAllFilters() {
    setState(() {
      _filterCategoryId = null;
      _minPrice = 0;
      _maxPrice = ActiveProductFilters.defaultMaxPrice;
      _minGrams = null;
      _maxGrams = null;
      _packingType = null;
      _sortOption = ProductSortOption.relevance;
    });
    _refreshVisibleList();
  }

  void _onSearchChanged(String query) {
    _refreshVisibleList();
  }

  List<Product> _buildVisibleList() {
    final filtered = applyCatalogFilters(
      products: _products,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minGrams: _minGrams,
      maxGrams: _maxGrams,
      packingType: _packingType,
    );
    final searched = _applySearch(filtered, _searchController.text);
    return sortProducts<Product>(
      products: searched,
      sort: _sortOption,
      priceOf: (p) => p.priceValue,
      nameOf: (p) => p.name,
    );
  }

  Future<void> _refreshVisibleListAsync() async {
    if (_packingType != null && _packingType!.trim().isNotEmpty) {
      final working = List<Product>.from(_products);
      await _productsController.enrichProductsPacking(working);
      if (!mounted) return;
      setState(() => _products = working);
    }
    _refreshVisibleList();
  }

  void _refreshVisibleList() {
    setState(() => _filteredProducts = _buildVisibleList());
  }

  Future<void> _openSort() async {
    final picked = await showProductSortSheet(context, current: _sortOption);
    if (picked == null || picked == _sortOption) return;
    setState(() => _sortOption = picked);
    _refreshVisibleList();
  }

  Future<void> _openFilters() async {
    final result = await Navigator.push<ProductFilterResult>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(initial: _filterInitial),
      ),
    );
    if (result == null || !mounted) return;

    final previousCategoryId = _selectedCategoryId;
    setState(() {
      if (result.categoryId != 0) {
        _filterCategoryId = result.categoryId;
        _selectedCategoryId = result.categoryId.toString();
        for (final cat in _categories) {
          if (int.tryParse(cat.id) == result.categoryId) {
            _selectedCategoryName = cat.name;
            break;
          }
        }
      } else {
        _filterCategoryId = null;
      }
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _minGrams = result.minGrams;
      _maxGrams = result.maxGrams;
      _packingType = result.packingType;
    });

    if (result.categoryId != 0 &&
        result.categoryId.toString() != previousCategoryId) {
      await _loadPage(reset: true);
      return;
    }

    await _refreshVisibleListAsync();
  }

  String get _sortChipLabel {
    if (_sortOption == ProductSortOption.relevance) return 'Sort';
    return _sortOption.label;
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      _loadPage();
    }
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _hasMore = true;
        _products.clear();
        _filteredProducts.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final page = reset ? 1 : _page;
      final batch = await _repository.fetchProductsByCategory(
        categoryId: _selectedCategoryId,
        limit: _pageSize,
        page: page,
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _products
            ..clear()
            ..addAll(batch);
        } else {
          _products.addAll(batch);
        }
        _filteredProducts = _buildVisibleList();
        _hasMore = batch.length >= _pageSize;
        if (_hasMore) _page = page + 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } on HomeRepositoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load products';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  List<Product> _applySearch(List<Product> products, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Widget _buildProductGrid(double gridWidth) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadPage(reset: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No products in this category',
          style: GoogleFonts.rubik(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadPage(reset: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(8, 4, 10, 12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
          childAspectRatio: gridWidth < 300 ? 0.62 : 0.66,
        ),
        itemCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredProducts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final product = _filteredProducts[index];
          return ProductCard(
            id: int.tryParse(product.id) ?? 0,
            name: product.name,
            grams: product.grams,
            stock: product.stock,
            price: product.price,
            imageUrl: product.imageUrl,
            onProductTap: () => openProductDetails(context, product),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = MediaQuery.of(context).size.width - _sidebarWidth;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedCategoryName,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.rubik(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search in $_selectedCategoryName...',
                hintStyle: GoogleFonts.rubik(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ProductFilterSortBar(
            onFiltersTap: _openFilters,
            onSortTap: _openSort,
            sortLabel: _sortChipLabel,
          ),
          AppliedFiltersBar(
            filters: _activeFilters,
            onClearAll: _clearAllFilters,
            onRemoveCategory: () {
              setState(() => _filterCategoryId = null);
            },
            onRemovePrice: () {
              setState(() {
                _minPrice = 0;
                _maxPrice = ActiveProductFilters.defaultMaxPrice;
              });
              _refreshVisibleList();
            },
            onRemoveWeight: () {
              setState(() {
                _minGrams = null;
                _maxGrams = null;
              });
              _refreshVisibleList();
            },
            onRemovePacking: (packing) {
              final remaining =
                  _packingTypesList.where((p) => p != packing).toList();
              setState(() {
                _packingType =
                    remaining.isEmpty ? null : remaining.join(',');
              });
              _refreshVisibleListAsync();
            },
            onRemoveSort: () {
              setState(() => _sortOption = ProductSortOption.relevance);
              _refreshVisibleList();
            },
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategorySidebar(
                  width: _sidebarWidth,
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  isLoading: _isLoadingCategories,
                  onCategorySelected: _selectCategory,
                ),
                Expanded(child: _buildProductGrid(gridWidth)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
