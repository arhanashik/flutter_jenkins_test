import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

/// Created by mdhasnain on 25 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.
///

abstract class HttpUtil {
  static const HEADER = {
    "Content-type": "application/json",
    "charset": "charset=utf-8",
  };
  static const TIMEOUT_DURATION = Duration(seconds: 30);

  static postReq(String url, Map data, {header = HEADER}) async {
    try {
      return await post(
          url, headers: header, body: jsonEncode(data)
      ).timeout(TIMEOUT_DURATION);
    } on TimeoutException catch (e) {
      print('Timeout $e');
      return HttpException(Code.TIMEOUT, e.message);
    } on SocketException catch (e) {
      print('Error: $e');
      return HttpException(Code.NOT_FOUND, e.message);
    } on Error catch (e) {
      print('Error: $e');
      return HttpException(Code.BAD_REQUEST, e.stackTrace.toString());
    }
  }
}

class HttpException {
  int statusCode;
  String message;

  HttpException(this.statusCode, this.message);
}

class Code {
  static const NOT_FOUND = 404;
  static const BAD_REQUEST = 500;
  static const TIMEOUT = 501;
}