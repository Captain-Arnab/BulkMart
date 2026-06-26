import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';

class VendorAddCategoryScreen extends StatefulWidget {
  const VendorAddCategoryScreen({super.key});

  @override
  State<VendorAddCategoryScreen> createState() =>
      _VendorAddCategoryScreenState();
}

class _VendorAddCategoryScreenState extends State<VendorAddCategoryScreen> {
  final _name = TextEditingController();
  final _iconName = TextEditingController();
  final _categoryIcon = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _iconName.dispose();
    _categoryIcon.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    final c = Get.find<VendorProductsController>();
    final ok = await c.addCategory(
      name: _name.text.trim(),
      iconName: _iconName.text.trim(),
      categoryIcon: _categoryIcon.text.trim(),
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Category name')),
            TextField(
                controller: _iconName,
                decoration: const InputDecoration(labelText: 'Icon name')),
            TextField(
                controller: _categoryIcon,
                decoration:
                    const InputDecoration(labelText: 'Category icon (URL)')),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Add Category')),
          ],
        ),
      ),
    );
  }
}
