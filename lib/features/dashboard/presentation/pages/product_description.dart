import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/tabbar.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/wishlist/wishlist_controller.dart';

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

    final cart = CartController.findOrPut();
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
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading product...',
                style: GoogleFonts.rubik(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _data == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
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
    final packingType = _data?['packingType']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.surfaceMint,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GlassIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GlassIconButton(
                  icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: _isFavorite ? Colors.red : Colors.black87,
                  onPressed: _toggleWishlist,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surfaceMint, AppColors.cardTint],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'product_${widget.productVal}',
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/sample.png',
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/sample.png',
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (packingType.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            InfoBadge(label: packingType.toUpperCase()),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _data?['grams'] ?? '',
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '\u20B9${_data?['price'] ?? '0'}',
                            style: GoogleFonts.rubik(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InfoBadge(label: '${_data?['gst'] ?? '5'}% GST'),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'In Stock: ${_data?['stock'] ?? '0'}',
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          QuantityStepper(
                            quantity: _quantity,
                            onDecrement: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            onIncrement: () => setState(() => _quantity++),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Add to Cart',
                              icon: Icons.shopping_cart_outlined,
                              isLoading: _isAddingToCart,
                              onPressed: _addToCart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 440,
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
          ),
        ],
      ),
    );
  }
}
