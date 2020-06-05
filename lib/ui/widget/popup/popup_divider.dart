import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class MyPopupMenuDivider<T> extends PopupMenuEntry<T> {
  const MyPopupMenuDivider({
    Key key,
    this.thickness: 1.5,
    this.color: AppColors.colorF1F1F1,
    this.padding: const EdgeInsets.symmetric(vertical: 0.0),
  }) : super(key: key);
  
  final double thickness;
  final Color color;
  final EdgeInsets padding;
  
  @override
  _PopupMenuDividerState<T> createState() => _PopupMenuDividerState<T>();

  @override
  double get height => thickness;

  @override
  bool represents(T value) => false;
}

class _PopupMenuDividerState<T> extends State<MyPopupMenuDivider<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Divider(
          height: widget.thickness,
          thickness: widget.thickness,
          color: widget.color
      ),
    );
  }
}