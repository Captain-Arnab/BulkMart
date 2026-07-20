import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';
import 'package:urban_roots/features/products/presentation/filterScreen.dart';
import 'package:urban_roots/features/products/presentation/widgets/applied_filters_bar.dart';
import 'package:urban_roots/features/products/presentation/widgets/category_sidebar.dart';
import 'package:urban_roots/features/products/presentation/widgets/product_filter_sort_bar.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    this.minGrams,
    this.maxGrams,
    this.packingType,
  });

  final int category;
  final double minPrice;
  final double maxPrice;
  final int? minGrams;
  final int? maxGrams;
  final String? packingType;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductsController productsController = Get.put(ProductsController());
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool isLoading = true;
  bool isCategoriesLoading = true;

  late int _category;
  late double _minPrice;
  late double _maxPrice;
  int? _minGrams;
  int? _maxGrams;
  String? _packingType;
  int? _filterCategoryId;
  ProductSortOption _sortOption = ProductSortOption.relevance;

  String get _selectedCategoryId => _category.toString();

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _minGrams = widget.minGrams;
    _maxGrams = widget.maxGrams;
    _packingType = widget.packingType;
    CartController.findOrPut().loadCart();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => isCategoriesLoading = true);
    await productsController.fetchCategories();
    if (!mounted) return;

    if (_category == 0 && productsController.categories.isNotEmpty) {
      _category = int.tryParse(productsController.categories.first.id) ?? 0;
    }

    setState(() => isCategoriesLoading = false);
    _fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    setState(() => isLoading = true);
    productsController
        .listProducts(
          context,
          _category,
          _minPrice,
          _maxPrice,
          _maxGrams,
          _minGrams,
          _packingType,
        )
        .then((products) {
      if (!mounted) return;
      setState(() {
        allProducts = products;
        filteredProducts = _buildVisibleList(products);
        isLoading = false;
      });
    });
  }

  List<Product> _buildVisibleList(List<Product> source) {
    final searched = _applySearch(source, _searchController.text);
    return sortProducts<Product>(
      products: searched,
      sort: _sortOption,
      priceOf: (p) => p.priceValue,
      nameOf: (p) => p.name,
    );
  }

  void _refreshVisibleList() {
    setState(() {
      filteredProducts = _buildVisibleList(allProducts);
    });
  }

  List<Product> _applySearch(List<Product> products, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  void _onCategorySelected(String categoryId) {
    final id = int.tryParse(categoryId) ?? 0;
    if (id == _category) return;
    setState(() {
      _category = id;
      _filterCategoryId = null;
    });
    _fetchProducts();
  }

  FilterScreenInitial get _filterInitial => FilterScreenInitial(
        categoryId: _filterCategoryId ?? 0,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minGrams: _minGrams,
        maxGrams: _maxGrams,
        packingTypes: _packingTypesList,
      );

  Future<void> _openFilters() async {
    final result = await Navigator.push<ProductFilterResult>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(initial: _filterInitial),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      if (result.categoryId != 0) {
        _category = result.categoryId;
        _filterCategoryId = result.categoryId;
      } else {
        _filterCategoryId = null;
      }
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _minGrams = result.minGrams;
      _maxGrams = result.maxGrams;
      _packingType = result.packingType;
    });
    _fetchProducts();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _refreshVisibleList();
    });
  }

  Future<void> _openSort() async {
    final picked = await showProductSortSheet(context, current: _sortOption);
    if (picked == null || picked == _sortOption) return;
    setState(() => _sortOption = picked);
    _refreshVisibleList();
  }

  String get _sortChipLabel {
    if (_sortOption == ProductSortOption.relevance) return 'Sort';
    return _sortOption.label;
  }

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
    for (final cat in productsController.categories) {
      if (int.tryParse(cat.id) == _filterCategoryId) return cat.name;
    }
    return null;
  }

  List<String> get _packingTypesList {
    if (_packingType == null || _packingType!.trim().isEmpty) return const [];
    return _packingType!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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
    _fetchProducts();
  }

  void _removePackingFilter(String packing) {
    final remaining = _packingTypesList.where((p) => p != packing).toList();
    setState(() {
      _packingType = remaining.isEmpty ? null : remaining.join(',');
    });
    _fetchProducts();
  }

  String get _categoryTitle {
    if (_category == 0) return 'All Products';
    for (final cat in productsController.categories) {
      if (int.tryParse(cat.id) == _category) return cat.name;
    }
    return 'Products';
  }

  static const double _sidebarWidth = 78;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth - _sidebarWidth;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _categoryTitle,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
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
                hintText: 'Search products...',
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
              _fetchProducts();
            },
            onRemoveWeight: () {
              setState(() {
                _minGrams = null;
                _maxGrams = null;
              });
              _fetchProducts();
            },
            onRemovePacking: _removePackingFilter,
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
                  categories: productsController.categories,
                  selectedCategoryId: _selectedCategoryId,
                  isLoading: isCategoriesLoading,
                  showAllOption: true,
                  onCategorySelected: _onCategorySelected,
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 56,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No products found',
                                    style: GoogleFonts.rubik(
                                      fontSize: 15,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 4, 10, 12),
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 10,
                                childAspectRatio:
                                    gridWidth < 300 ? 0.62 : 0.66,
                              ),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ProductCard(
                                  id: int.tryParse(product.id) ?? 0,
                                  productId: product.id,
                                  name: product.name,
                                  grams: product.grams,
                                  stock: product.stock,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  offerLabel: product.offerLabel,
                                  onProductTap: () =>
                                      openProductDetails(context, product),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
