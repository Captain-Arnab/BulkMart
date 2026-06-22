import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/data/repositories/home_repository.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

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
  final _scrollController = ScrollController();

  final List<Product> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadPage(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final page = reset ? 1 : _page;
      final batch = await _repository.fetchProductsByCategory(
        categoryId: widget.categoryId,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null && _products.isEmpty
              ? Center(
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
                )
              : _products.isEmpty
                  ? Center(
                      child: Text(
                        'No products in this category',
                        style: GoogleFonts.rubik(color: Colors.grey.shade600),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _loadPage(reset: true),
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: screenWidth < 400 ? 0.65 : 0.72,
                        ),
                        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _products.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }
                          final product = _products[index];
                          return ProductCard(
                            id: int.tryParse(product.id) ?? 0,
                            name: product.name,
                            grams: product.grams,
                            stock: product.stock,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            onProductTap: () =>
                                openProductDetails(context, product),
                          );
                        },
                      ),
                    ),
    );
  }
}
