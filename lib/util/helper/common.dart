import 'package:flutter/material.dart';

class Common {
  static DateTime convertToDateTime(String dateStr) {
    return DateTime.parse(dateStr);
  }

  static double toDp(BuildContext context,double px) {
    final screenSize = MediaQuery.of(context).size;
    return (screenSize.width / screenSize.height) * px;
  }
}