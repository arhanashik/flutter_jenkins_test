import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o2o/app.dart';

void main() {

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blue
  ));

  runApp(O2OApp());
}
