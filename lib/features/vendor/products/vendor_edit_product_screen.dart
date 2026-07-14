import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_products_controller.dart';
import 'package:urban_roots/features/vendor/models/vendor_models.dart';

class VendorEditProductScreen extends StatefulWidget {
  const VendorEditProductScreen({super.key, required this.product});

  final VendorProductItem product;

  @override
  State<VendorEditProductScreen> createState() =>
      _VendorEditProductScreenState();
}

class _VendorEditProductScreenState extends State<VendorEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _stock;
  late final TextEditingController _gst;
  late final TextEditingController _descriptions;
  late final TextEditingController _imageUrl;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _removedExistingImage = false;

  String get _existingImageUrl => resolveImageUrl(widget.product.imageUrl);

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
    _imageUrl = TextEditingController(
      text: p.imageUrl.startsWith('http') ? p.imageUrl : '',
    );
  }

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
        setState(() {
          _pickedImage = file;
          _removedExistingImage = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Could not pick image', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showImageSourceSheet() {
    final hasImage = _pickedImage != null ||
        (!_removedExistingImage && _existingImageUrl.isNotEmpty);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove image'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _pickedImage = null;
                    _removedExistingImage = true;
                    _imageUrl.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Get.find<VendorProductsController>();
    final ok = await c.updateProduct(
      productId: widget.product.id,
      name: _name.text.trim(),
      price: _price.text.trim(),
      category: _category.text.trim(),
      stock: _stock.text.trim(),
      gst: _gst.text.trim(),
      descriptions: _descriptions.text.trim(),
      weight: widget.product.weight,
      status: widget.product.status,
      imagePath: _pickedImage?.path,
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProductsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Edit Product',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _sectionLabel('Product image'),
            const SizedBox(height: 10),
            _buildImagePicker(),
            const SizedBox(height: 12),
            _field(
              _imageUrl,
              'Or paste image URL',
              keyboard: TextInputType.url,
              hint: 'https://…',
            ),
            const SizedBox(height: 8),
            _sectionLabel('Details'),
            const SizedBox(height: 10),
            _field(_name, 'Name', required: true),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    _price,
                    'Price',
                    required: true,
                    keyboard: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _stock,
                    'Stock',
                    required: true,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(_category, 'Category', required: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _gst,
                    'GST %',
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            _field(_descriptions, 'Description', maxLines: 3),
            const SizedBox(height: 8),
            Obx(() => FilledButton(
                  onPressed: c.isLoading.value ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.rubik(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _imagePreviewContent(),
      ),
    );
  }

  Widget _imagePreviewContent() {
    if (_pickedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
          _editBadge(),
        ],
      );
    }

    if (!_removedExistingImage && _existingImageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _existingImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _uploadPlaceholder(),
          ),
          _editBadge(),
        ],
      );
    }

    return _uploadPlaceholder();
  }

  Widget _editBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        radius: 18,
        child: IconButton(
          iconSize: 18,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: _showImageSourceSheet,
        ),
      ),
    );
  }

  Widget _uploadPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
        SizedBox(height: 8),
        Text('Tap to upload image',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 2),
        Text('Gallery or Camera',
            style: TextStyle(fontSize: 12, color: AppColors.hint)),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: GoogleFonts.rubik(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
      ),
    );
  }
}
