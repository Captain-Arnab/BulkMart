import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'moq_badge.dart';
import 'product_network_image.dart';

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
                  ProductNetworkImage(product: product),
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
}
