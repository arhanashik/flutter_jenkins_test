import 'package:flutter/material.dart';

/// Created by mdhasnain on 03 Mar, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => (maxHeight > minHeight)? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(
      child: Container(
        color: overlapsContent ? Colors.red : Colors.lightBlue,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}