import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Created by mdhasnain
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Provides necessary converter functions
/// 2.
/// 3.
class Converter {
  ///Convert the given string date string to DateTime
  static DateTime toDateTime(String dateStr) {
    return DateTime.parse(dateStr);
  }

  ///Convert px value to android's dp value
  static double toDp(BuildContext context, double px) {
    final screenSize = MediaQuery.of(context).size;
    return (screenSize.width / screenSize.height) * px;
  }

  ///Format the given price to comma(,) separated string
  static String formatPrice(int number) {
    final formatter = new NumberFormat("###,##,##,###");
    return '¥' + formatter.format(number);
  }
}