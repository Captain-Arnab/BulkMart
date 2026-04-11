import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final double _minPrice = 0;
  final double _maxPrice = 2000;
  double _currentMinPrice = 0;
  double _currentMaxPrice = 2000;

  ProductsController productsController = Get.find<ProductsController>();

  Map<String, bool> selectedCategories = {};
  bool isLoadingCategories = true;

  List<String> gramsRanges = ['0-100', '101-500', '501-1000'];
  Map<String, bool> selectedGrams = {};

  List<String> packingTypes = ['UNIQUE POUCH', 'COMMON POUCH', 'Glass Jar'];
  Map<String, bool> selectedPackingTypes = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeFilters();
  }

  void _initializeFilters() {
    for (var range in gramsRanges) {
      selectedGrams[range] = false;
    }
    for (var type in packingTypes) {
      selectedPackingTypes[type] = false;
    }
  }

  Future<void> _loadCategories() async {
    setState(() => isLoadingCategories = true);

    await productsController.fetchCategories();
    for (var category in productsController.categories) {
      selectedCategories[category.id] = false;
    }

    setState(() => isLoadingCategories = false);
  }

  void _applyFilters() {
    List<String> selectedCategoryIds = selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    List<String> selectedGramsFilters = selectedGrams.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    int? minGrams;
    int? maxGrams;

    if (selectedGramsFilters.isNotEmpty) {
      String gramsRange = selectedGramsFilters.first;
      List<String> gramsParts = gramsRange.split('-');
      minGrams = int.tryParse(gramsParts[0]);
      maxGrams = int.tryParse(gramsParts[1]);
    }

    String? packingType;
    List<String> selectedPackingTypeFilters = selectedPackingTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedPackingTypeFilters.isNotEmpty) {
      packingType = selectedPackingTypeFilters.join(',');
    }

    int categoryId = 0;
    if (selectedCategoryIds.length == 1) {
      categoryId = int.tryParse(selectedCategoryIds.first) ?? 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(
          category: categoryId,
          minPrice: _currentMinPrice,
          maxPrice: _currentMaxPrice,
          minGrams: minGrams,
          maxGrams: maxGrams,
          packingType: packingType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Filter Products',
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RangeSlider(
              values: RangeValues(_currentMinPrice, _currentMaxPrice),
              min: _minPrice,
              max: _maxPrice,
              divisions: 100,
              activeColor: Theme.of(context).primaryColor,
              labels: RangeLabels(
                '\u20B9${_currentMinPrice.round()}',
                '\u20B9${_currentMaxPrice.round()}',
              ),
              onChanged: (RangeValues values) {
                if (values.start < values.end) {
                  setState(() {
                    _currentMinPrice = values.start;
                    _currentMaxPrice = values.end;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text('Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoadingCategories
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator()))
                : productsController.categories.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('No categories available'))
                    : Column(
                        children:
                            productsController.categories.map((category) {
                          return CheckboxListTile(
                            title: Text(category.name),
                            value:
                                selectedCategories[category.id] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedCategories[category.id] =
                                    value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
            SizedBox(height: 16),
            Text('Weight Range (grams)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...gramsRanges.map((range) => CheckboxListTile(
                  title: Text('${range}g'),
                  value: selectedGrams[range],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedGrams[range] = value ?? false;
                    });
                  },
                )),
            SizedBox(height: 16),
            Text('Packing Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...packingTypes.map((type) => CheckboxListTile(
                  title: Text(type),
                  value: selectedPackingTypes[type],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedPackingTypes[type] = value ?? false;
                    });
                  },
                )),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Apply Filters',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
