import 'package:flutter/material.dart';

/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class ShapedWidget extends StatelessWidget {
  ShapedWidget({
    @required this.child,
    this.background: Colors.white,
    this.borderRadius: 5.0,
    this.padding: 5.0,
  });
  final Color background;
  final double borderRadius;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
          clipBehavior: Clip.antiAlias,
          color: background,
          shape: _ShapedWidgetBorder(
            side: BorderSide(color: background),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              padding: padding
          ),
          elevation: 4.0,
          child: child,
      )
    );
  }
}

class _ShapedWidgetBorder extends RoundedRectangleBorder {
  _ShapedWidgetBorder({
    @required this.padding,
    side = BorderSide.none,
    borderRadius = BorderRadius.zero,
  }) : super(side: side, borderRadius: borderRadius);
  final double padding;

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..moveTo(rect.width - 16.0, rect.top)
      ..lineTo(rect.width - 24.0, rect.top - 10.0)
      ..lineTo(rect.width - 32.0, rect.top)
      ..addRRect(borderRadius.resolve(textDirection).toRRect(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height)
      ));
  }
}