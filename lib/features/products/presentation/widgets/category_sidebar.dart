import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/category_icon_helper.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart'
    show Category;

/// Blinkit-style vertical category column on the left of the product grid.
class CategorySidebar extends StatelessWidget {
  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
    this.showAllOption = false,
    this.width = 78,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final bool isLoading;
  final bool showAllOption;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: categories.length + (showAllOption ? 1 : 0),
              itemBuilder: (context, index) {
                if (showAllOption && index == 0) {
                  return _SidebarItem(
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

                return _SidebarItem(
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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

  static const double _iconSize = 46;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? NetworkOrAssetImage(
                        url: imageUrl!,
                        width: _iconSize,
                        height: _iconSize,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        icon ?? fallbackIcon ?? Icons.category_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 8.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF333333),
                height: 1.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
