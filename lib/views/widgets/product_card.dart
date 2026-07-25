import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'moq_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.paper2,
                          AppColors.paper,
                          _categoryTint(product.categoryId),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _categoryIcon(product.categoryId),
                        size: 36,
                        color: AppColors.forest.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: MoqBadge(label: product.moqStamp, size: 40, fontSize: 8),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.unitSize,
                      style: AppTextStyles.body(fontSize: 10.5, color: AppColors.slate),
                    ),
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _priceFormat.format(product.wholesalePrice),
                            style: AppTextStyles.mono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestDark,
                            ),
                          ),
                          TextSpan(
                            text: ' /${product.unitLabel}',
                            style: AppTextStyles.mono(
                              fontSize: 9.5,
                              color: AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _categoryTint(String id) {
    switch (id) {
      case 'oil':
        return const Color(0xFFE8D9A8);
      case 'spices':
        return const Color(0xFFE5C4A8);
      case 'dal':
        return const Color(0xFFD4C9A8);
      case 'flour':
        return const Color(0xFFEDE6D0);
      case 'sugar':
        return const Color(0xFFE0E8E2);
      default:
        return AppColors.paper;
    }
  }

  static IconData _categoryIcon(String id) {
    switch (id) {
      case 'oil':
        return Icons.water_drop_outlined;
      case 'spices':
        return Icons.spa_outlined;
      case 'dal':
        return Icons.grain_outlined;
      case 'flour':
        return Icons.bakery_dining_outlined;
      case 'sugar':
        return Icons.cookie_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
