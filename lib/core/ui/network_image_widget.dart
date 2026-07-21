import 'package:flutter/material.dart';
import 'package:urban_roots/core/config/api_config.dart';

/// Builds a full image URL from API-relative or absolute paths.
String resolveImageUrl(String? raw) {
  if (raw == null) return '';
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final root = ApiConfig.siteRoot;
  if (trimmed.startsWith('/')) return '$root$trimmed';
  return '$root/$trimmed';
}

String pickImageUrl(Map<String, dynamic> json) {
  for (final key in [
    'main_image',
    'imageUrl',
    'image_url',
    'product_image',
    'image',
    'banner_image',
    'categ_image',
    'category_image',
    'photo',
    'thumbnail',
  ]) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return resolveImageUrl(value);
    }
  }

  final images = json['images'];
  if (images is List) {
    for (final entry in images) {
      if (entry is String && entry.trim().isNotEmpty) {
        return resolveImageUrl(entry);
      }
      if (entry is Map) {
        final nested = pickImageUrl(Map<String, dynamic>.from(entry));
        if (nested.isNotEmpty) return nested;
      }
    }
  }

  return '';
}

/// Default placeholder when a product has no image or the image fails to load.
const String kProductPlaceholderAsset = 'assets/logo.png';

class NetworkOrAssetImage extends StatelessWidget {
  const NetworkOrAssetImage({
    super.key,
    required this.url,
    this.assetFallback = kProductPlaceholderAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackFit = BoxFit.contain,
    this.borderRadius,
  });

  final String? url;
  final String assetFallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxFit fallbackFit;
  final BorderRadius? borderRadius;

  Widget _assetImage() {
    return Image.asset(
      assetFallback,
      width: width,
      height: height,
      fit: fallbackFit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveImageUrl(url);
    Widget image;
    if (resolved.isNotEmpty) {
      final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
      final cacheW = _cachePx(width, dpr);
      final cacheH = _cachePx(height, dpr);
      image = Image.network(
        resolved,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW,
        cacheHeight: cacheH,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _assetImage(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      image = _assetImage();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  /// Decode images at display size to avoid full-res decode jank on lists.
  static int? _cachePx(double? logical, double dpr) {
    if (logical == null) return null;
    if (!logical.isFinite || logical <= 0) return null;
    return (logical * dpr).round().clamp(1, 2000);
  }
}
