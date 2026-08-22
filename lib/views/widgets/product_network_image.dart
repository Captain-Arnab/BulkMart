import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/colors.dart';
import 'remote_network_image.dart';

/// Product catalog image from admin cover [Product.imageUrl] only — no stock photos.
class ProductNetworkImage extends StatelessWidget {
  const ProductNetworkImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.iconSize = 36,
  });

  final Product product;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? (constraints.maxWidth * dpr).round().clamp(40, 720)
            : 320;
        final cacheH = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? (constraints.maxHeight * dpr).round().clamp(40, 720)
            : 320;

        if (!product.hasImage) {
          return _placeholder();
        }

        return RemoteNetworkImage(
          imageUrl: product.imageUrl!,
          fit: fit,
          memCacheWidth: cacheW,
          memCacheHeight: cacheH,
          errorWidget: _placeholder(),
        );
      },
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.paper2,
      child: Center(
        child: Icon(
          Icons.local_florist_outlined,
          size: iconSize,
          color: AppColors.slate.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
