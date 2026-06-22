import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';
import 'package:urban_roots/features/products/presentation/filterScreen.dart';
import 'package:urban_roots/features/products/presentation/widgets/category_icons_row.dart';

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

  late int _category;
  late double _minPrice;
  late double _maxPrice;
  int? _minGrams;
  int? _maxGrams;
  String? _packingType;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _minGrams = widget.minGrams;
    _maxGrams = widget.maxGrams;
    _packingType = widget.packingType;
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
        filteredProducts = products;
        isLoading = false;
      });
    });
  }

  Future<void> _openFilters() async {
    final result = await Navigator.push<ProductFilterResult>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen()),
    );
    if (result == null || !mounted) return;

    setState(() {
      _category = result.categoryId;
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
      setState(() {
        filteredProducts = allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'All Products',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune, color: Color(0xFF019934)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF019934),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const CategoryIconsRow(),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF019934)),
              ),
            )
          else if (filteredProducts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No products found',
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth < 400 ? 0.65 : 0.72,
                ),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    id: int.tryParse(product.id) ?? 0,
                    name: product.name,
                    grams: product.grams,
                    stock: product.stock,
                    price: product.price,
                    imageUrl: product.imageUrl,
                    offerLabel: product.offerLabel,
                    onProductTap: () => openProductDetails(context, product),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
