import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

/// Created by mdhasnain on 03 Mar, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3. 

class TopBar extends StatelessWidget implements PreferredSizeWidget {

  TopBar({
    @required this.title,
    @required this.navigationIcon,
    this.iconColor = AppColors.colorBlue,
    this.background = Colors.white,
    this.menu,
    this.onTapNavigation,
  }) : preferredSize = Size.fromHeight(60.0);
  final String title;
  final Widget navigationIcon;
  final Color iconColor;
  final Color background;
  final Widget menu;
  final Function onTapNavigation;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 50.0,
        color: background,
        padding: EdgeInsets.symmetric(horizontal: 13.0),
        alignment: Alignment.center,
        child:
//        Stack(
//          alignment: AlignmentDirectional.topStart,
//          children: <Widget>[
//            navigationIcon,
//            Stack(
//              alignment: AlignmentDirectional.topEnd,
//              children: <Widget>[
//                menu == null? Container() : menu,
//
//              ],
//            )
//          ],
//        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: navigationIcon,
              onTap: () => onTapNavigation == null
                  ? Navigator.of(context).pop() : onTapNavigation(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700
                ),
                textAlign: TextAlign.center,
              ),
            ),
            menu == null? Container(width: 64.0,) : menu,
          ],
        ),
      ),
    );
  }

  @override
  final Size preferredSize;
}