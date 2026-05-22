import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_products_navigator.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_routes.dart';
import 'package:urban_roots/features/vendor/products/product_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductViewModel _vm;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _vm = ProductViewModel();
    _vm.addListener(() => setState(() {}));
    _vm.loadProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Product Details', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF019934),
        onPressed: () {
          vendorProductsPush(
            context,
            VendorRoutes.addEditProduct,
            arguments: widget.productId,
          );
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = _vm.detailState;
    if (state is UiLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF019934)));
    }
    if (state is UiError<VendorProduct?>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: GoogleFonts.rubik()),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => _vm.loadProductDetail(widget.productId), child: const Text('Retry')),
          ],
        ),
      );
    }
    final product = (state as UiSuccess<VendorProduct?>).data!;
    final images = [product.imageAsset, ...product.galleryAssets];

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 240,
                viewportFraction: 1,
                onPageChanged: (i, _) => setState(() => _carouselIndex = i),
              ),
              items: images.map((asset) {
                return Image.asset(asset, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 240, color: Colors.grey.shade200));
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedSmoothIndicator(
                activeIndex: _carouselIndex,
                count: images.length,
                effect: const WormEffect(dotHeight: 8, dotWidth: 8, activeDotColor: Color(0xFF019934)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(product.name, style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                  _ProductStatusChip(status: product.status),
                ],
              ),
              const SizedBox(height: 8),
              Text('₹${product.price.toStringAsFixed(0)} · GST ${product.gstPercent}% · Stock ${product.stock}',
                  style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text('Category: ${product.category}', style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              _Section(title: 'Short Description', body: product.shortDescription),
              _Section(title: 'Health Benefits', body: product.healthBenefits),
              _Section(title: 'USP', body: product.usp),
              _Section(title: 'Nutritional Info', body: product.nutritionalInfo),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductStatusChip extends StatelessWidget {
  const _ProductStatusChip({required this.status});

  final VendorProductStatus status;

  Color get _color {
    switch (status) {
      case VendorProductStatus.online:
        return const Color(0xFF019934);
      case VendorProductStatus.draft:
        return Colors.grey;
      case VendorProductStatus.outOfStock:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(body, style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
        ],
      ),
    );
  }
}
