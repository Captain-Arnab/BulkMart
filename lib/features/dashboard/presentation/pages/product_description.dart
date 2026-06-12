import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/domain/cart_controller.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/tabbar.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/wishlist/domain/wishlist_controller.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productVal;
  final Product? preview;
  const ProductDetailsPage({
    super.key,
    required this.productVal,
    this.preview,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductsController productsController = Get.put(ProductsController());
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _loadProductData();
    _loadWishlistState();
  }

  Future<void> _loadWishlistState() async {
    final inList =
        await WishlistController.findOrPut().isInWishlist(widget.productVal);
    if (mounted) setState(() => _isFavorite = inList);
  }

  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await productsController.fetchProductData(
      widget.productVal,
      preview: widget.preview,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (data.isEmpty) {
        _errorMessage = productsController.errorMessage.value.isNotEmpty
            ? productsController.errorMessage.value
            : 'Could not load product details';
        _data = null;
      } else {
        _data = data;
      }
    });
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);

    final cart = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final success =
        await cart.addProduct(widget.productVal, quantity: _quantity);

    if (!mounted) return;
    setState(() => _isAddingToCart = false);

    if (success) {
      await SweetAlert.success(
        context,
        message: '${_data?['name']} added to cart',
      );
    } else {
      await SweetAlert.error(
        context,
        message: cart.errorMessage.value.isNotEmpty
            ? cart.errorMessage.value
            : 'Could not add to cart',
      );
    }
  }

  Future<void> _toggleWishlist() async {
    final wishlist = WishlistController.findOrPut();
    final nextAdd = !_isFavorite;
    final success = await wishlist.toggle(widget.productVal, add: nextAdd);
    if (!mounted) return;

    if (success) {
      setState(() => _isFavorite = nextAdd);
      await SweetAlert.success(
        context,
        message: nextAdd ? 'Added to wishlist' : 'Removed from wishlist',
      );
    } else {
      await SweetAlert.error(
        context,
        message: wishlist.errorMessage.value.isNotEmpty
            ? wishlist.errorMessage.value
            : 'Could not update wishlist',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF019934)),
        ),
      );
    }

    if (_errorMessage != null || _data == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ApiStateView(
          status: ApiViewStatus.error,
          errorMessage: _errorMessage ?? 'Product not found',
          onRetry: _loadProductData,
          child: const SizedBox.shrink(),
        ),
      );
    }

    final imageUrl = resolveImageUrl(_data?['imageUrl']?.toString());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: _toggleWishlist,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF0F7F0),
                child: Center(
                  child: Hero(
                    tag: 'product_${widget.productVal}',
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/sample.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/sample.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _data?['name'] ?? '',
                            style: GoogleFonts.rubik(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if ((_data?['packingType']?.toString() ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _data?['packingType'] ?? '',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF019934),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _data?['grams'] ?? '',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '\u20B9${_data?['price'] ?? '0'}',
                          style: GoogleFonts.rubik(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF019934),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_data?['gst'] ?? '5'}% GST',
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'In Stock: ${_data?['stock'] ?? '0'}',
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Text(
                                '$_quantity',
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF019934),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _isAddingToCart ? null : _addToCart,
                              icon: _isAddingToCart
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              label: Text(
                                'Add to Cart',
                                style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 420,
                      child: TabBarWidget(
                        name: _data?['name'] ?? 'Product',
                        description: _data?['description'] ?? '',
                        healthBenefits: _data?['healthBenefits'] ?? '',
                        nutritionalInfo: _data?['nutritionalInfo'] ?? '',
                        sellingPoints: _data?['sellingPoints'] ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
