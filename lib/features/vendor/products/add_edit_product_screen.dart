import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/products/product_view_model.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, this.productId});

  final String? productId;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _hsnController = TextEditingController();
  final _eanController = TextEditingController();
  final _weightController = TextEditingController();
  final _stockController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _longDescController = TextEditingController();
  final _healthController = TextEditingController();
  final _uspController = TextEditingController();
  final _nutritionController = TextEditingController();

  String? _category;
  int _gst = 5;
  String _packageType = 'Pouch';
  VendorProductStatus _status = VendorProductStatus.draft;
  bool _loading = false;

  final _categories = ['Nuts', 'Dry Fruits', 'Millets', 'Herbs', 'Spices'];
  final _gstOptions = [0, 5, 12, 18, 28];
  final _packageTypes = ['Pouch', 'Box', 'Jar', 'Bulk'];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadForEdit();
  }

  Future<void> _loadForEdit() async {
    setState(() => _loading = true);
    final vm = ProductViewModel();
    await vm.loadProductDetail(widget.productId!);
    if (vm.detailState is UiSuccess<VendorProduct?>) {
      final p = (vm.detailState as UiSuccess<VendorProduct?>).data;
      if (p != null) {
        _nameController.text = p.name;
        _priceController.text = p.price.toStringAsFixed(0);
        _hsnController.text = p.hsnCode;
        _eanController.text = p.eanCode;
        _weightController.text = '${p.weightGrams}';
        _stockController.text = '${p.stock}';
        _shortDescController.text = p.shortDescription;
        _healthController.text = p.healthBenefits;
        _uspController.text = p.usp;
        _nutritionController.text = p.nutritionalInfo;
        _category = p.category;
        _gst = p.gstPercent;
        _status = p.status;
      }
    }
    vm.dispose();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _hsnController.dispose();
    _eanController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    _shortDescController.dispose();
    _longDescController.dispose();
    _healthController.dispose();
    _uspController.dispose();
    _nutritionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      await SweetAlert.warning(context, message: 'Please select a category');
      return;
    }
    await SweetAlert.success(
      context,
      message: widget.productId == null ? 'Product saved (mock)' : 'Product updated (mock)',
      onConfirm: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF019934)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _imagePickerSection(),
                  const SizedBox(height: 16),
                  _field(_nameController, 'Product Name *', validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  _field(_priceController, 'Price *', keyboard: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid price';
                    return null;
                  }),
                  _field(_hsnController, 'HSN Code'),
                  _field(_eanController, 'EAN Code'),
                  _dropdown('Category *', _category, _categories, (v) => setState(() => _category = v)),
                  _field(_weightController, 'Weight (grams)', keyboard: TextInputType.number),
                  _field(_stockController, 'Stock quantity', keyboard: TextInputType.number),
                  _dropdown('GST %', '$_gst%', _gstOptions.map((e) => '$e%').toList(),
                      (v) => setState(() => _gst = int.parse(v!.replaceAll('%', '')))),
                  _dropdown('Package Type', _packageType, _packageTypes, (v) => setState(() => _packageType = v!)),
                  _dropdown('Status', _status.label,
                      VendorProductStatus.values.map((s) => s.label).toList(),
                      (v) => setState(() => _status = VendorProductStatus.values.firstWhere((s) => s.label == v))),
                  _multiline(_shortDescController, 'Short Description'),
                  _multiline(_longDescController, 'Long Description'),
                  _multiline(_healthController, 'Health Benefits'),
                  _multiline(_uspController, 'USP'),
                  _multiline(_nutritionController, 'Nutritional Info'),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF019934),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Save', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _imagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _imagePlaceholder('Main', large: true),
            const SizedBox(width: 8),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _imagePlaceholder('${i + 1}'),
            )),
          ],
        ),
        Text('Tap to pick (API upload later)', style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _imagePlaceholder(String label, {bool large = false}) {
    final size = large ? 88.0 : 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: large ? 28 : 20, color: Colors.grey),
          Text(label, style: GoogleFonts.rubik(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboard, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _multiline(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
