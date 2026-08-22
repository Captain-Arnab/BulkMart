import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

import '../../theme/colors.dart';

bool isAvifImageUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.avif');
}

/// Network image for admin uploads (JPG, PNG, WEBP, GIF, AVIF).
class RemoteNetworkImage extends StatelessWidget {
  const RemoteNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.errorWidget,
    this.placeholder,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? errorWidget;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final loading = placeholder ?? const ColoredBox(color: AppColors.paper2);
    final error = errorWidget ?? loading;

    if (isAvifImageUrl(imageUrl)) {
      return CachedNetworkAvifImage(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => error,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loading;
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => loading,
      errorWidget: (_, __, ___) => error,
    );
  }
}
