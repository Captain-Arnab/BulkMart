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

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProductsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(() {
        if (c.isLoading.value && c.products.isEmpty) {
          return const LoadingView(label: 'Loading products...');
        }
        if (c.errorMessage.value.isNotEmpty && c.products.isEmpty) {
          return FailureView(
              message: c.errorMessage.value, onRetry: c.loadProducts);
        }
        final filtered = c.filteredProducts;
        final lowStock = c.products.where((p) {
          final s = int.tryParse(p.stock) ?? 0;
          return s <= 10;
        }).length;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.loadProducts,
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.scaffold,
              foregroundColor: Colors.black87,
              elevation: 0,
              title: Text('Products',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  tooltip: 'Add category',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorAddCategoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.category_outlined),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total',
                        value: '${c.products.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Showing',
                        value: '${filtered.length}',
                        icon: Icons.filter_list_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Low Stock',
                        value: '$lowStock',
                        icon: Icons.warning_amber_rounded,
                        accent: lowStock > 0
                            ? const Color(0xFFE08600)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _SearchBar(onChanged: c.setSearch),
              ),
            ),
            SliverToBoxAdapter(child: _CategoryFilter(controller: c)),
            if (filtered.isEmpty)
              SliverFillRemaining(
                child: EmptyView(
                  icon: Icons.inventory_2_outlined,
                  message: c.products.isEmpty
                      ? 'No products yet'
                      : 'No matching products',
                  subtitle: c.products.isEmpty
                      ? 'Tap + to add your first product.'
                      : 'Try a different search or category.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductCard(
                      product: filtered[index],
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VendorEditProductScreen(product: filtered[index]),
                          ),
                        );
                        await c.loadProducts();
                      },
                      onDelete: () => _confirmDelete(context, c, filtered[index]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () async {
          final c = Get.find<VendorProductsController>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendorAddProductScreen()),
          );
          await c.loadProducts();
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Product',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.rubik(fontSize: 10, color: AppColors.hint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: GoogleFonts.rubik(color: AppColors.hint, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      if (cats.isEmpty) return const SizedBox(height: 8);
      final selected = controller.selectedCategory.value;
      final chips = <String>['', ...cats];
      return SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final value = chips[i];
            final label = value.isEmpty ? 'All' : value;
            final isSelected = value == selected;
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(value),
              showCheckmark: false,
              labelStyle: GoogleFonts.rubik(
                fontSize: 12,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _lowStock
              ? const Color(0xFFE08600).withValues(alpha: 0.35)
              : AppColors.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹${product.price}',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _stockBadge(),
                        ],
                      ),
                      if (product.category.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          product.category,
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            color: AppColors.hint,
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
                    const SizedBox(height: 6),
                    _iconButton(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFD32F2F),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final url = product.imageUrl.trim();
    final isNetwork = url.startsWith('http');
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
            color: AppColors.primary, size: 28),
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
