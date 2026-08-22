import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarouselImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const CarouselImage({super.key, required this.url, this.fit = BoxFit.fitHeight});

  bool get isSvg => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (isSvg) {
      return SvgPicture.network(
        url,
        fit: fit,
        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: 1000, // 🚀 Improve loading speed by caching resized version
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
    );
  }
}
