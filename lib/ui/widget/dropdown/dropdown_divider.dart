import 'package:flutter/material.dart';

/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class DropdownDivider<T> extends PopupMenuEntry<T> {
  @override
  _DropdownDividerState<T> createState() => _DropdownDividerState<T>();

  @override
  double get height => 1.0;

  @override
  bool represents(T value) => false;
}

class _DropdownDividerState<T> extends State<DropdownDivider<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(height: 1.0, color: Colors.grey.shade400),
    );
  }
}