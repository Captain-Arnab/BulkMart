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

class NetworkOrAssetImage extends StatelessWidget {
  const NetworkOrAssetImage({
    super.key,
    required this.url,
    this.assetFallback = 'assets/sample.png',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final String assetFallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveImageUrl(url);
    Widget image;
    if (resolved.isNotEmpty) {
      image = Image.network(
        resolved,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          assetFallback,
          width: width,
          height: height,
          fit: fit,
        ),
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
      image = Image.asset(
        assetFallback,
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
