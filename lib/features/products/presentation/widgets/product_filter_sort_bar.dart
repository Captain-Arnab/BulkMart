import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

enum ProductSortOption {
  relevance('Relevance'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low'),
  nameAz('Name: A to Z');

  const ProductSortOption(this.label);
  final String label;
}

/// Blinkit-style Filters + Sort chips — aligned to the right below search.
class ProductFilterSortBar extends StatelessWidget {
  const ProductFilterSortBar({
    super.key,
    required this.onFiltersTap,
    required this.onSortTap,
    this.sortLabel,
  });

  final VoidCallback onFiltersTap;
  final VoidCallback onSortTap;
  final String? sortLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _FilterSortChip(
            label: 'Filters',
            icon: Icons.tune_rounded,
            onTap: onFiltersTap,
          ),
          const SizedBox(width: 8),
          _FilterSortChip(
            label: sortLabel ?? 'Sort',
            icon: Icons.swap_vert_rounded,
            onTap: onSortTap,
          ),
        ],
      ),
    );
  }
}

class _FilterSortChip extends StatelessWidget {
  const _FilterSortChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF4A4A4A)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<ProductSortOption?> showProductSortSheet(
  BuildContext context, {
  required ProductSortOption current,
}) {
  return showModalBottomSheet<ProductSortOption>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sort by',
                style: GoogleFonts.rubik(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              ...ProductSortOption.values.map((option) {
                final selected = option == current;
                return Material(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      option.label,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 22,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, option),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

List<T> sortProducts<T>({
  required List<T> products,
  required ProductSortOption sort,
  required double Function(T) priceOf,
  required String Function(T) nameOf,
}) {
  final list = List<T>.from(products);
  switch (sort) {
    case ProductSortOption.relevance:
      return list;
    case ProductSortOption.priceLowHigh:
      list.sort((a, b) => priceOf(a).compareTo(priceOf(b)));
      return list;
    case ProductSortOption.priceHighLow:
      list.sort((a, b) => priceOf(b).compareTo(priceOf(a)));
      return list;
    case ProductSortOption.nameAz:
      list.sort(
        (a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()),
      );
      return list;
  }
}
