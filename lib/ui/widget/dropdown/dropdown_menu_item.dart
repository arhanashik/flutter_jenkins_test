import 'package:flutter/material.dart';

/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class DropdownMenuItem<T> extends PopupMenuEntry<T> {
  const DropdownMenuItem({
    Key key,
    this.value,
    @required this.text,
  })  : assert(text != null),
        super(key: key);

  final T value;

  final String text;

  @override
  _DropdownMenuItemState<T> createState() => _DropdownMenuItemState<T>();

  @override
  double get height => 32.0;

  @override
  bool represents(T value) => this.value == value;
}

class _DropdownMenuItemState<T> extends State<DropdownMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop<T>(widget.value),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 10.0,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}