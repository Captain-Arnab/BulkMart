import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/product.dart';
import '../../theme/colors.dart';

/// Network product image with shimmer placeholder, Picsum fallback, broken-icon final fail.
class ProductNetworkImage extends StatefulWidget {
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
  State<ProductNetworkImage> createState() => _ProductNetworkImageState();
}

class _ProductNetworkImageState extends State<ProductNetworkImage> {
  late String _url;
  bool _usingFallback = false;

  @override
  void initState() {
    super.initState();
    _url = widget.product.primaryImageUrl;
    _usingFallback = widget.product.imageUrl == null || widget.product.imageUrl!.isEmpty;
  }

  @override
  void didUpdateWidget(covariant ProductNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        oldWidget.product.imageUrl != widget.product.imageUrl) {
      _url = widget.product.primaryImageUrl;
      _usingFallback =
          widget.product.imageUrl == null || widget.product.imageUrl!.isEmpty;
    }
  }

  void _onPrimaryFailed() {
    if (_usingFallback) return;
    setState(() {
      _usingFallback = true;
      _url = widget.product.fallbackImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _url,
      fit: widget.fit,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.paper2,
        highlightColor: AppColors.white,
        child: Container(color: AppColors.paper2),
      ),
      errorWidget: (_, __, ___) {
        if (!_usingFallback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onPrimaryFailed();
          });
          return Shimmer.fromColors(
            baseColor: AppColors.paper2,
            highlightColor: AppColors.white,
            child: Container(color: AppColors.paper2),
          );
        }
        return ColoredBox(
          color: AppColors.paper2,
          child: Icon(
            Icons.broken_image_outlined,
            size: widget.iconSize,
            color: AppColors.slate.withValues(alpha: 0.55),
          ),
        );
      },
    );
  }
}
