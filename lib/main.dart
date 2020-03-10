import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o2o/app.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

void main() {

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.colorBlue
  ));

  runApp(O2OApp());
}
