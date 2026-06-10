import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/shimmer_widgets.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_products_navigator.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_routes.dart';
import 'package:urban_roots/features/vendor/products/product_view_model.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProductViewModel();
    _viewModel.addListener(_onVmUpdate);
    _viewModel.loadProducts();
  }

  void _onVmUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onVmUpdate);
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(VendorProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete product?', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        content: Text(
          'Remove "${product.name}"? This cannot be undone.',
          style: GoogleFonts.rubik(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.rubik(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await _viewModel.deleteProduct(product.id);
      if (!mounted) return;
      if (ok) {
        await SweetAlert.success(context, message: 'Product deleted');
      } else {
        await SweetAlert.error(context, message: 'Failed to delete product');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Products', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Categories',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => vendorProductsPush(context, VendorRoutes.categoryList),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _viewModel.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.green.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF019934),
        onPressed: () => vendorProductsPush(context, VendorRoutes.addEditProduct, arguments: null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Product', style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBody() {
    final state = _viewModel.productsState;

    if (state is UiLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerProductTile(),
      );
    }

    if (state is UiError<List<VendorProduct>>) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(state.message, textAlign: TextAlign.center, style: GoogleFonts.rubik(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _viewModel.loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final products = _viewModel.filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _viewModel.searchQuery.isEmpty ? 'No products yet' : 'No matching products',
              style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first product',
              style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF019934),
      onRefresh: _viewModel.loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Dismissible(
            key: ValueKey(product.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await _confirmDelete(product);
              return false;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: Colors.red.shade400,
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: _ProductListTile(
              product: product,
              onTap: () => vendorProductsPush(
                context,
                VendorRoutes.productDetail,
                arguments: product.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product, required this.onTap});

  final VendorProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.imageAsset,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(0)} · Stock ${product.stock}',
                    style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  _StatusChip(status: product.status),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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
