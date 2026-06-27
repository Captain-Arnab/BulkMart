import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  final _imageUrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _category.dispose();
    _stock.dispose();
    _gst.dispose();
    _descriptions.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() => _pickedImage = file);
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Could not pick image', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_pickedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove selected image'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _pickedImage = null);
                },
              ),
          ],
        ),
      ),
    );
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
      images: _imageUrl.text.trim(),
      imagePath: _pickedImage?.path,
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
            _field(_price, 'Price',
                required: true, keyboard: TextInputType.number),
            _field(_category, 'Category', required: true),
            _field(_stock, 'Stock',
                required: true, keyboard: TextInputType.number),
            _field(_gst, 'GST', keyboard: TextInputType.number),
            _field(_descriptions, 'Descriptions', maxLines: 3),
            _buildImagePicker(),
            const SizedBox(height: 12),
            _field(
              _imageUrl,
              'Or paste image URL (optional)',
              keyboard: TextInputType.url,
            ),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Product Image',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 18,
                          child: IconButton(
                            iconSize: 18,
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _showImageSourceSheet,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 40, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text('Tap to upload image',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Gallery or Camera',
                          style: TextStyle(fontSize: 12, color: AppColors.hint)),
                    ],
                  ),
          ),
        ),
      ],
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
