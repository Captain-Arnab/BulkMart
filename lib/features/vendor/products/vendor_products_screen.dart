import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/categories/vendor_add_category_screen.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';
import 'package:urban_roots/features/vendor/products/vendor_add_product_screen.dart';
import 'package:urban_roots/features/vendor/products/vendor_edit_product_screen.dart';

/// Vendor products tab — search, filter, list, add, edit, delete.
class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProductsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Products',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_category') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorAddCategoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'add_category',
                child: Text('Add Category'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendorAddProductScreen()),
          );
          await c.loadProducts();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.products.isEmpty) {
          return const LoadingView(label: 'Loading products...');
        }
        if (c.errorMessage.value.isNotEmpty && c.products.isEmpty) {
          return FailureView(
              message: c.errorMessage.value, onRetry: c.loadProducts);
        }
        return Column(
          children: [
            _SearchBar(onChanged: c.setSearch),
            _CategoryFilter(controller: c),
            Expanded(child: _buildList(context, c)),
          ],
        );
      }),
    );
  }

  Widget _buildList(BuildContext context, VendorProductsController c) {
    final products = c.filteredProducts;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: c.loadProducts,
      child: products.isEmpty
          ? EmptyView(
              icon: Icons.inventory_2_outlined,
              message: c.products.isEmpty
                  ? 'No products yet'
                  : 'No matching products',
              subtitle: c.products.isEmpty
                  ? 'Tap "Add Product" to create your first listing.'
                  : 'Try a different search or category.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 2),
                    child: Text(
                      '${products.length} '
                      '${products.length == 1 ? 'product' : 'products'}',
                      style: GoogleFonts.rubik(
                          fontSize: 13, color: AppColors.hint),
                    ),
                  );
                }
                final p = products[index - 1];
                return _ProductCard(
                  product: p,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendorEditProductScreen(product: p),
                      ),
                    );
                    await c.loadProducts();
                  },
                  onDelete: () => _confirmDelete(context, c, p),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VendorProductsController c,
    VendorProductItem p,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete product?'),
        content: Text('Remove "${p.name}" from your listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await c.deleteProduct(p.id);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: GoogleFonts.rubik(color: AppColors.hint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.controller});

  final VendorProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.categories;
      if (cats.isEmpty) return const SizedBox(height: 4);
      final selected = controller.selectedCategory.value;
      final chips = <String>['', ...cats]; // '' = All
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final value = chips[i];
            final label = value.isEmpty ? 'All' : value;
            final isSelected = value == selected;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(value),
              showCheckmark: false,
              labelStyle: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final VendorProductItem product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _lowStock {
    final s = int.tryParse(product.stock) ?? 0;
    return s <= 10;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _thumbnail(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.isEmpty ? 'Unnamed product' : product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${product.price}',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _stockBadge(),
                  ],
                ),
                if (product.category.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: GoogleFonts.rubik(
                          fontSize: 11, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              _iconButton(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                onTap: onEdit,
              ),
              const SizedBox(height: 4),
              _iconButton(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFD32F2F),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    final url = product.imageUrl.trim();
    final isNetwork = url.startsWith('http');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetwork
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderIcon(),
              loadingBuilder: (ctx, child, progress) =>
                  progress == null ? child : _placeholderIcon(),
            )
          : _placeholderIcon(),
    );
  }

  Widget _placeholderIcon() => const Center(
        child: Icon(Icons.inventory_2_outlined,
            color: AppColors.primary, size: 26),
      );

  Widget _stockBadge() {
    final color = _lowStock ? const Color(0xFFE08600) : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Stock ${product.stock}',
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
