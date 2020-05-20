import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/popup/popup_shape.dart';

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
  });
  final Color background;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
          clipBehavior: Clip.antiAlias,
          color: background,
          shape: PopupShape(
            side: BorderSide(color: background),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          elevation: 4.0,
          child: child,
      )
    );
  }
}