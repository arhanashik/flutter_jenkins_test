import 'package:flutter/cupertino.dart';

/// Created by mdhasnain on 28 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class PopupShape extends RoundedRectangleBorder {
  PopupShape({
    side = BorderSide.none,
    borderRadius = BorderRadius.zero,
  }) : super(side: side, borderRadius: borderRadius);

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