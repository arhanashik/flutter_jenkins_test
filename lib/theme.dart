import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

ThemeData buildTheme() {

  TextStyle _buildTitleTheme() {
    return TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }

  AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
        color: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        textTheme: TextTheme(
          title: _buildTitleTheme(),
        ),
        elevation: 0,
    );
  }

  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
//      headline: base.headline.copyWith(
//        fontFamily: 'Merriweather',
//        fontSize: 40.0,
//        color: const Color(0xFF807a6b),
//      ),
//      title: base.title.copyWith(
//        color: Colors.black
//      ),
    );
  }

//  final ThemeData base = ThemeData.light();
  final ThemeData base = ThemeData(fontFamily: 'NotoSansCJKjp');

  return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: _buildAppBarTheme(),
      backgroundColor: AppColors.background,
  );

//  return ThemeData(fontFamily: 'NotoSansCJKjp');
}
