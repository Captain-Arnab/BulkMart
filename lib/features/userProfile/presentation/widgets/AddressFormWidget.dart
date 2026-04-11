import 'package:flutter/material.dart';

import '../../model/Address.dart';

class AddressFormWidget extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  AddressFormWidget({this.address, required this.onSave});

  @override
  _AddressFormWidgetState createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for address lines, pincode, and instructions
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedCategory = 'Home';

  // State and city dropdown variables
  String? _selectedState;
  String? _selectedCity;

  // State and city data
  final Map<String, List<String>> _stateCityMap = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Karnataka': ['Bangalore', 'Mysore', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
    'Delhi': ['New Delhi'],
    // Add more states and cities as needed
  };

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _addressLine1Controller.text = widget.address!.addressLine1;
      _addressLine2Controller.text = widget.address!.addressLine2 ?? '';
      _pincodeController.text = widget.address!.pincode;
      _selectedCategory = widget.address!.category;
      _instructionsController.text = widget.address!.deliveryInstructions ?? '';
      _selectedState = widget.address!.state;
      _selectedCity = widget.address!.city;
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _pincodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Address Line 1
              TextFormField(
                controller: _addressLine1Controller,
                decoration: InputDecoration(labelText: 'Address Line 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Address Line 1';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Address Line 2
              TextFormField(
                controller: _addressLine2Controller,
                decoration: InputDecoration(labelText: 'Address Line 2'),
              ),
              SizedBox(height: 10),

              // State Dropdown
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: InputDecoration(labelText: 'State'),
                items: _stateCityMap.keys.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                    _selectedCity = null; // Reset city when state changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // City Dropdown (depends on selected state)
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(labelText: 'City'),
                items: _selectedState != null
                    ? _stateCityMap[_selectedState]!.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList()
                    : [],
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Pincode
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a pincode';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: ['Home', 'Work', 'Others'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 10),

              // Delivery Instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Delivery Instructions'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newAddress = Address(
                addressLine1: _addressLine1Controller.text.trim(),
                addressLine2: _addressLine2Controller.text.trim(),
                state: _selectedState!,
                city: _selectedCity!,
                pincode: _pincodeController.text.trim(),
                category: _selectedCategory,
                deliveryInstructions: _instructionsController.text.trim(),
              );
              widget.onSave(newAddress);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.address == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
