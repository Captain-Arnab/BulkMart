import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';

import '../../model/Address.dart';

class AddressFormWidget extends StatefulWidget {
  final Address? address;
  final Future<bool> Function(Address) onSave;

  const AddressFormWidget({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedCategory = 'Home';
  bool _isDefault = false;
  bool _isSaving = false;

  static const _categories = ['Home', 'Work', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final address = widget.address!;
      _fullNameController.text = address.fullName;
      _phoneController.text = address.phone;
      _addressLine1Controller.text = address.addressLine1;
      _addressLine2Controller.text = address.addressLine2 ?? '';
      _cityController.text = address.city;
      _stateController.text = address.state;
      _pincodeController.text = address.pincode;
      _selectedCategory = address.category;
      _instructionsController.text = address.deliveryInstructions ?? '';
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 20, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surfaceMint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: GoogleFonts.rubik(
        fontSize: 13,
        color: Colors.grey.shade700,
      ),
      hintStyle: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address type',
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final selected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(
                category,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              selected: selected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (_) => setState(() => _selectedCategory = category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final newAddress = Address(
      id: widget.address?.id ?? '',
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty
          ? null
          : _addressLine2Controller.text.trim(),
      state: _stateController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      category: _selectedCategory,
      deliveryInstructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
      isDefault: _isDefault,
    );

    final success = await widget.onSave(newAddress);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      await SweetAlert.error(context, message: 'Could not save address');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Address' : 'Add Address',
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Where should we deliver your order?',
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle('Contact details'),
                      TextFormField(
                        controller: _fullNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _fieldDecoration(
                          'Full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _fieldDecoration(
                          'Phone number',
                          icon: Icons.phone_outlined,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter phone number';
                          }
                          if (value.trim().length < 10) {
                            return 'Enter a valid 10-digit number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(
                        'Delivery address',
                        subtitle: 'House no., street, area',
                      ),
                      TextFormField(
                        controller: _addressLine1Controller,
                        decoration: _fieldDecoration(
                          'Address line',
                          icon: Icons.home_outlined,
                        ),
                        maxLines: 2,
                        minLines: 1,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressLine2Controller,
                        decoration: _fieldDecoration(
                          'Landmark',
                          hint: 'Near park, opposite mall…',
                          icon: Icons.place_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _fieldDecoration('State'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _fieldDecoration('City'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _pincodeController,
                        decoration: _fieldDecoration(
                          'Pincode',
                          icon: Icons.pin_drop_outlined,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter pincode';
                          }
                          if (value.trim().length != 6) {
                            return 'Enter 6-digit pincode';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _addressTypeChips(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        minLines: 2,
                        decoration: _fieldDecoration(
                          'Delivery instructions',
                          hint: 'Ring the bell, leave at door…',
                          icon: Icons.notes_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Set as default address',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Use this address for future orders',
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          value: _isDefault,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.45),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppColors.primary
                                : Colors.grey.shade400,
                          ),
                          onChanged: (value) =>
                              setState(() => _isDefault = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Save changes' : 'Save address',
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
