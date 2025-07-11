import 'package:flutter/material.dart';

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
  const WebImageWidget(this.url, {
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
    return const Text('Unsupported platform');
  }
}