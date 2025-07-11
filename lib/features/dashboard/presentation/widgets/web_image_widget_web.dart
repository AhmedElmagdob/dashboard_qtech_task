import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web; // ضروري

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

  /// [url] is required. Other params have defaults:
  /// width: 40, height: 40, fit: BoxFit.cover,
  /// borderRadius: circular(8), borderColor: transparent,
  /// borderWidth: 0, isCircular: false
  WebImageWidget(
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
      }) : super(key: key) {
    // Register once per unique URL
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      url,
          (int viewId) => html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: url),
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

    return GestureDetector(
      onTap: onTap,
      child: image,
    );
  }
}

