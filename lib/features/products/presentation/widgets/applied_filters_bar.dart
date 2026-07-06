import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/products/presentation/widgets/product_filter_sort_bar.dart';

class ActiveProductFilters {
  const ActiveProductFilters({
    this.categoryName,
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.minGrams,
    this.maxGrams,
    this.packingTypes = const [],
    this.sort = ProductSortOption.relevance,
  });

  static const double defaultMaxPrice = 2000;

  final String? categoryName;
  final double minPrice;
  final double maxPrice;
  final int? minGrams;
  final int? maxGrams;
  final List<String> packingTypes;
  final ProductSortOption sort;

  bool get hasCategoryFilter =>
      categoryName != null && categoryName!.trim().isNotEmpty;

  bool get hasPriceFilter =>
      minPrice > 0 || maxPrice < defaultMaxPrice;

  bool get hasWeightFilter =>
      minGrams != null && maxGrams != null && minGrams! > 0 && maxGrams! > 0;

  bool get hasPackingFilter => packingTypes.isNotEmpty;

  bool get hasSortFilter => sort != ProductSortOption.relevance;

  bool get hasAny =>
      hasCategoryFilter ||
      hasPriceFilter ||
      hasWeightFilter ||
      hasPackingFilter ||
      hasSortFilter;
}

/// Shows active filter/sort chips below the filter bar on product listings.
class AppliedFiltersBar extends StatelessWidget {
  const AppliedFiltersBar({
    super.key,
    required this.filters,
    this.onClearAll,
    this.onRemoveCategory,
    this.onRemovePacking,
    this.onRemovePrice,
    this.onRemoveWeight,
    this.onRemoveSort,
  });

  final ActiveProductFilters filters;
  final VoidCallback? onClearAll;
  final VoidCallback? onRemoveCategory;
  final ValueChanged<String>? onRemovePacking;
  final VoidCallback? onRemovePrice;
  final VoidCallback? onRemoveWeight;
  final VoidCallback? onRemoveSort;

  @override
  Widget build(BuildContext context) {
    if (!filters.hasAny) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (filters.hasCategoryFilter) {
      chips.add(
        _AppliedChip(
          label: filters.categoryName!,
          onRemove: onRemoveCategory,
        ),
      );
    }

    if (filters.hasPriceFilter) {
      chips.add(
        _AppliedChip(
          label:
              '\u20B9${filters.minPrice.round()} - \u20B9${filters.maxPrice.round()}',
          onRemove: onRemovePrice,
        ),
      );
    }

    if (filters.hasWeightFilter) {
      chips.add(
        _AppliedChip(
          label: '${filters.minGrams}g - ${filters.maxGrams}g',
          onRemove: onRemoveWeight,
        ),
      );
    }

    for (final packing in filters.packingTypes) {
      chips.add(
        _AppliedChip(
          label: packing,
          onRemove:
              onRemovePacking != null ? () => onRemovePacking!(packing) : null,
        ),
      );
    }

    if (filters.hasSortFilter) {
      chips.add(
        _AppliedChip(
          label: filters.sort.label,
          onRemove: onRemoveSort,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Row(
            children: [
              Text(
                'Applied filters',
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              if (onClearAll != null)
                GestureDetector(
                  onTap: onClearAll,
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, index) => chips[index],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _AppliedChip extends StatelessWidget {
  const _AppliedChip({
    required this.label,
    this.onRemove,
  });

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
