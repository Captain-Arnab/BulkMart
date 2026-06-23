import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorEditProductScreen extends StatefulWidget {
  const VendorEditProductScreen({super.key, required this.product});

  final VendorProductItem product;

  @override
  State<VendorEditProductScreen> createState() => _VendorEditProductScreenState();
}

class _VendorEditProductScreenState extends State<VendorEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _stock;
  late final TextEditingController _gst;
  late final TextEditingController _descriptions;
  late final TextEditingController _images;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p.name);
    _price = TextEditingController(text: p.price);
    _category = TextEditingController(text: p.category);
    _stock = TextEditingController(text: p.stock);
    _gst = TextEditingController(text: p.gst);
    _descriptions = TextEditingController(text: p.descriptions);
    _images = TextEditingController(text: p.imageUrl);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _category.dispose();
    _stock.dispose();
    _gst.dispose();
    _descriptions.dispose();
    _images.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Get.find<VendorProductsController>();
    final ok = await c.updateProduct({
      'product_id': widget.product.id,
      'name': _name.text.trim(),
      'price': _price.text.trim(),
      'category': _category.text.trim(),
      'stock': _stock.text.trim(),
      'gst': _gst.text.trim(),
      'descriptions': _descriptions.text.trim(),
      'images': _images.text.trim(),
    });
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProductsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
            TextFormField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
            TextFormField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock')),
            TextFormField(controller: _gst, decoration: const InputDecoration(labelText: 'GST')),
            TextFormField(controller: _descriptions, maxLines: 3, decoration: const InputDecoration(labelText: 'Descriptions')),
            TextFormField(controller: _images, decoration: const InputDecoration(labelText: 'Images')),
            const SizedBox(height: 20),
            Obx(() => FilledButton(
                  onPressed: c.isLoading.value ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: c.isLoading.value
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Save Changes'),
                )),
          ],
        ),
      ),
    );
  }
}
