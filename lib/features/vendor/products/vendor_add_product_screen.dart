import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';

class VendorAddProductScreen extends StatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController();
  final _stock = TextEditingController();
  final _gst = TextEditingController(text: '5');
  final _descriptions = TextEditingController();
  final _images = TextEditingController();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Get.find<VendorProductsController>();
    final ok = await c.addProduct(
      name: _name.text.trim(),
      price: _price.text.trim(),
      category: _category.text.trim(),
      stock: _stock.text.trim(),
      gst: _gst.text.trim(),
      descriptions: _descriptions.text.trim(),
      images: _images.text.trim(),
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProductsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'Name', required: true),
            _field(_price, 'Price', required: true, keyboard: TextInputType.number),
            _field(_category, 'Category', required: true),
            _field(_stock, 'Stock', required: true, keyboard: TextInputType.number),
            _field(_gst, 'GST', keyboard: TextInputType.number),
            _field(_descriptions, 'Descriptions', maxLines: 3),
            _field(_images, 'Images (URL or path)'),
            const SizedBox(height: 20),
            Obx(() => FilledButton(
                  onPressed: c.isLoading.value ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: c.isLoading.value
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Add Product'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
      ),
    );
  }
}
