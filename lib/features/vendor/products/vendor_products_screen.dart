import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/categories/vendor_add_category_screen.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';
import 'package:urban_roots/features/vendor/products/vendor_add_product_screen.dart';
import 'package:urban_roots/features/vendor/products/vendor_edit_product_screen.dart';

/// Vendor products tab — list, add, edit, delete.
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
                child: Text('Manage Categories → Add Category'),
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
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.products.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (c.errorMessage.value.isNotEmpty && c.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.errorMessage.value, textAlign: TextAlign.center),
                ElevatedButton(
                    onPressed: c.loadProducts, child: const Text('Retry')),
              ],
            ),
          );
        }
        final products = c.filteredProducts;
        if (products.isEmpty) {
          return const Center(child: Text('No products yet'));
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.loadProducts,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(p.name,
                      style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '₹${p.price} · Stock ${p.stock} · ${p.category}',
                    style: GoogleFonts.rubik(fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VendorEditProductScreen(product: p),
                            ),
                          );
                          await c.loadProducts();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade400),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete product?'),
                              content: Text('Remove "${p.name}"?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true) await c.deleteProduct(p.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
