import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;

/// Horizontal category strip — selecting a category filters products in place
/// (Blinkit-style), instead of opening a separate screen.
class CategorySelectorRow extends StatelessWidget {
  const CategorySelectorRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
    this.showAllOption = false,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final bool isLoading;
  final bool showAllOption;

  static const double _itemWidth = 76;
  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 92,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (categories.isEmpty && !showAllOption) {
      return const SizedBox.shrink();
    }

    final itemCount = categories.length + (showAllOption ? 1 : 0);

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (showAllOption && index == 0) {
            return _CategoryChip(
              label: 'All',
              isSelected: selectedCategoryId == '0',
              icon: Icons.grid_view_rounded,
              onTap: () => onCategorySelected('0'),
            );
          }

          final categoryIndex = showAllOption ? index - 1 : index;
          final category = categories[categoryIndex];
          final isSelected = category.id == selectedCategoryId;
          final hasImage = category.image.trim().isNotEmpty;

          return _CategoryChip(
            label: category.name,
            isSelected: isSelected,
            imageUrl: hasImage ? category.image : null,
            fallbackIcon: categoryFallbackIcon(category.name),
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.imageUrl,
    this.fallbackIcon,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: CategorySelectorRow._itemWidth,
        child: Column(
          children: [
            Container(
              width: CategorySelectorRow._iconSize,
              height: CategorySelectorRow._iconSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.15),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? NetworkOrAssetImage(
                        url: imageUrl!,
                        width: CategorySelectorRow._iconSize,
                        height: CategorySelectorRow._iconSize,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        icon ?? fallbackIcon ?? Icons.category_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black87,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
