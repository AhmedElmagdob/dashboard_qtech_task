import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WebImageWidget extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback? onTap;
  final Color borderColor;
  final double borderWidth;
  final bool isCircular;
  /// [url] is required. All other parameters have defaults:
  /// width: 40, height: 40, fit: BoxFit.cover, borderRadius: BorderRadius.circular(8)
  const WebImageWidget(
      this.url, {
        Key? key,
        this.width = 40,
        this.height = 40,
        this.fit = BoxFit.cover,
        this.borderRadius = const BorderRadius.all(Radius.circular(8)),
        this.onTap,
        this.borderColor = Colors.transparent,
        this.borderWidth = 0,
        this.isCircular = false,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey, size: 24),
      ),
    );
    if (isCircular) {
      image = ClipOval(child: image);
    } else {
      image = ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    if (borderWidth > 0) {
      image = Container(
        decoration: BoxDecoration(
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : borderRadius,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: image,
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: image,
    );
  }
}