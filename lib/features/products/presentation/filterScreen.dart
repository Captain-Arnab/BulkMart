import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class ProductFilterResult {
  const ProductFilterResult({
    required this.categoryId,
    required this.minPrice,
    required this.maxPrice,
    this.minGrams,
    this.maxGrams,
    this.packingType,
  });

  final int categoryId;
  final double minPrice;
  final double maxPrice;
  final int? minGrams;
  final int? maxGrams;
  final String? packingType;
}

class FilterScreenInitial {
  const FilterScreenInitial({
    this.categoryId = 0,
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.minGrams,
    this.maxGrams,
    this.packingTypes = const [],
  });

  final int categoryId;
  final double minPrice;
  final double maxPrice;
  final int? minGrams;
  final int? maxGrams;
  final List<String> packingTypes;
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, this.initial});

  final FilterScreenInitial? initial;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const double _minPrice = 0;
  static const double _maxPrice = 2000;

  double _currentMinPrice = 0;
  double _currentMaxPrice = 2000;

  final ProductsController productsController = Get.find<ProductsController>();

  final Map<String, bool> _selectedCategories = {};
  bool _isLoadingCategories = true;

  final List<String> _gramsRanges = const ['0-100', '101-500', '501-1000'];
  String? _selectedGramsRange;

  final List<String> _packingTypes = const [
    'UNIQUE POUCH',
    'COMMON POUCH',
    'Glass Jar',
  ];
  final Set<String> _selectedPackingTypes = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _setPricesFromInitial(initial.minPrice, initial.maxPrice);
      _selectedGramsRange = _gramsRangeFromValues(
        initial.minGrams,
        initial.maxGrams,
      );
      _selectedPackingTypes.addAll(initial.packingTypes);
      _pendingCategoryId = initial.categoryId;
    }
    _loadCategories();
  }

  void _setPricesFromInitial(double minPrice, double maxPrice) {
    final hasActiveMaxFilter = maxPrice < _maxPrice;

    var min = minPrice.clamp(_minPrice, _maxPrice);
    var max = hasActiveMaxFilter
        ? maxPrice.clamp(_minPrice, _maxPrice)
        : _maxPrice;

    if (min >= max) {
      min = _minPrice;
      max = _maxPrice;
    }

    _currentMinPrice = min;
    _currentMaxPrice = max;
  }

  RangeValues get _priceRangeValues {
    var start = _currentMinPrice.clamp(_minPrice, _maxPrice);
    var end = _currentMaxPrice.clamp(_minPrice, _maxPrice);
    if (start >= end) {
      start = _minPrice;
      end = _maxPrice;
    }
    return RangeValues(start, end);
  }

  int _pendingCategoryId = 0;

  String? _gramsRangeFromValues(int? minGrams, int? maxGrams) {
    if (minGrams == null || maxGrams == null) return null;
    for (final range in _gramsRanges) {
      final parts = range.split('-');
      if (parts.length != 2) continue;
      if (int.tryParse(parts[0]) == minGrams &&
          int.tryParse(parts[1]) == maxGrams) {
        return range;
      }
    }
    return null;
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    await productsController.fetchCategories();
    for (final category in productsController.categories) {
      _selectedCategories[category.id] =
          int.tryParse(category.id) == _pendingCategoryId;
    }
    if (mounted) setState(() => _isLoadingCategories = false);
  }

  void _clearAll() {
    setState(() {
      _currentMinPrice = _minPrice;
      _currentMaxPrice = _maxPrice;
      _selectedGramsRange = null;
      _selectedPackingTypes.clear();
      _pendingCategoryId = 0;
      for (final key in _selectedCategories.keys) {
        _selectedCategories[key] = false;
      }
    });
  }

  void _toggleCategory(String id) {
    setState(() {
      final wasSelected = _selectedCategories[id] ?? false;
      for (final key in _selectedCategories.keys) {
        _selectedCategories[key] = false;
      }
      _selectedCategories[id] = !wasSelected;
      _pendingCategoryId = !wasSelected ? (int.tryParse(id) ?? 0) : 0;
    });
  }

  void _applyFilters() {
    int? minGrams;
    int? maxGrams;
    if (_selectedGramsRange != null) {
      final parts = _selectedGramsRange!.split('-');
      minGrams = int.tryParse(parts[0]);
      maxGrams = int.tryParse(parts[1]);
    }

    String? packingType;
    if (_selectedPackingTypes.isNotEmpty) {
      packingType = _selectedPackingTypes.join(',');
    }

    var categoryId = 0;
    for (final entry in _selectedCategories.entries) {
      if (entry.value) {
        categoryId = int.tryParse(entry.key) ?? 0;
        break;
      }
    }

    Navigator.pop(
      context,
      ProductFilterResult(
        categoryId: categoryId,
        minPrice: _currentMinPrice,
        maxPrice: _currentMaxPrice,
        minGrams: minGrams,
        maxGrams: maxGrams,
        packingType: packingType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSectionCard(
                    title: 'Price range',
                    subtitle: 'Select your budget',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _PriceBox(
                              label: 'Min',
                              value: '\u20B9${_currentMinPrice.round()}',
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            _PriceBox(
                              label: 'Max',
                              value: '\u20B9${_currentMaxPrice.round()}',
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            thumbColor: AppColors.primary,
                            overlayColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            trackHeight: 4,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                          ),
                          child: RangeSlider(
                            values: _priceRangeValues,
                            min: _minPrice,
                            max: _maxPrice,
                            divisions: 40,
                            onChanged: (values) {
                              if (values.start < values.end) {
                                setState(() {
                                  _currentMinPrice = values.start;
                                  _currentMaxPrice = values.end;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSectionCard(
                    title: 'Category',
                    subtitle: 'Pick one category',
                    child: _isLoadingCategories
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : productsController.categories.isEmpty
                            ? Text(
                                'No categories available',
                                style: GoogleFonts.rubik(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: productsController.categories
                                    .map((category) {
                                  final selected =
                                      _selectedCategories[category.id] ??
                                          false;
                                  final hasImage =
                                      category.image.trim().isNotEmpty;
                                  return _SelectableChip(
                                    label: category.name,
                                    selected: selected,
                                    leading: hasImage
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: NetworkOrAssetImage(
                                              url: category.image,
                                              width: 22,
                                              height: 22,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            categoryFallbackIcon(
                                                category.name),
                                            size: 16,
                                            color: selected
                                                ? AppColors.primary
                                                : Colors.grey.shade600,
                                          ),
                                    onTap: () =>
                                        _toggleCategory(category.id),
                                  );
                                }).toList(),
                              ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSectionCard(
                    title: 'Weight',
                    subtitle: 'Filter by pack size',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _gramsRanges.map((range) {
                        final selected = _selectedGramsRange == range;
                        return _SelectableChip(
                          label: '${range}g',
                          selected: selected,
                          onTap: () {
                            setState(() {
                              _selectedGramsRange =
                                  selected ? null : range;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSectionCard(
                    title: 'Packaging',
                    subtitle: 'Type of packaging',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _packingTypes.map((type) {
                        final selected = _selectedPackingTypes.contains(type);
                        return _SelectableChip(
                          label: type,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedPackingTypes.remove(type);
                              } else {
                                _selectedPackingTypes.add(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.black87,
              ),
              Expanded(
                child: Text(
                  'Filters',
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Clear all',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Show results',
              style: GoogleFonts.rubik(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  const _FilterSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rubik(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.rubik(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : const Color(0xFFF7F9F7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : const Color(0xFFE0E4E0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : const Color(0xFF333333),
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
