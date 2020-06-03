import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o2o/app.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

///This is the starting point of the app.
/// Created by mdhasnain
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Calls main function for starting the app
/// 2. Changes the default status bar color
/// 3.
void main() {

  ///By default the status bar is not same as our expected color.
  ///So, custom color is being set by overriding the system UI.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.colorBlue
  ));

  ///Let's call and run the app
  runApp(O2OApp());
}