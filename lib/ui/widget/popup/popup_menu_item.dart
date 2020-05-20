import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class MyPopupMenuItem<T> extends PopupMenuEntry<T> {
  const MyPopupMenuItem({
    Key key,
    this.value,
    @required this.text,
    this.icon,
    this.onTap,
  })  : assert(text != null),
        super(key: key);

  final T value;

  final String text;
  final Widget icon;
  final Function onTap;

  @override
  _DropdownMenuItemState<T> createState() => _DropdownMenuItemState<T>();

  @override
  double get height => 32.0;

  @override
  bool represents(T value) => this.value == value;
}

class _DropdownMenuItemState<T> extends State<MyPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.icon == null? Container() : widget.icon,
            Text(
              widget.text,
              style: TextStyle(
                  color: AppColors.colorBlueDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop<T>(widget.value);
        widget.onTap();
      },
    );
  }
}