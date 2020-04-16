import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

/// Created by mdhasnain on 25 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Making http requests from one place
/// 2. Providing the api urls from one place
/// 3. Providing the request/response code and status from one place
///

abstract class HttpUtil {

  static const _HOME_PC = 'http://192.168.100.122:8080';
  static const _SAI_HOME_PC = 'http://192.168.11.2:8080';
  static const _SAI_OFFICE_PC = 'http://192.168.4.166:8080';
  static const _DEV_SERVER = 'http://128.168.76.221:8080/';
  static const _BASE_URL = '$_DEV_SERVER/api/v1';

  static const LOGIN = '$_BASE_URL/login';
  static const REGISTER_IMEI = '$_BASE_URL/timeorder/list';

  static const GET_TIME_ORDER = '$_BASE_URL/timeorder/list';
  static const GET_TIME_ORDER_HISTORY = '$_BASE_URL/timeorderhistory/list';

  static const GET_ORDER_LIST = '$_BASE_URL/orderlist/list';

  static const UPDATE_PICKING_STATUS = '$_BASE_URL/picking/status/update';
  static const GET_PICKING_LIST = '$_BASE_URL/picking/list';
  static const CHECK_PICKED_ITEM = '$_BASE_URL/picking/details';
  static const UPDATE_PICKING_COUNT = '$_BASE_URL/picking/product/status/update';

  static const UPDATE_PACKING_STATUS = '$_BASE_URL/packing/status/update';
  static const GET_PACKING_LIST = '$_BASE_URL/packing/list';
  static const UPDATE_RECEIPT_NUMBER = '$_BASE_URL/packing/receipt_no/update';
  static const CHECK_PACKING_QR_CODE = '$_BASE_URL/packing/qr_code/judge';
  static const UPDATE_PACKING_QR_CODE = '$_BASE_URL/packing/qrCode/update';

  static const HEADER = {
    "Content-type": "application/json",
    "charset": "charset=utf-8",
  };
  static const TIMEOUT_DURATION = Duration(seconds: 10);
  static final client = Client();

  static get(String url, {Map params, header = HEADER}) async {
    try {
      url = _constructQueryUrl(url, params);
//      final uri = Uri.http(url, '', data);
      print('request:: (get) $url');
      final response = await client.get(
          url, headers: header
      ).timeout(TIMEOUT_DURATION);
      print('response:: code: ${response.statusCode}, body: ${response.body}');
      return response;
    } on TimeoutException catch (e) {
      print('Timeout $e');
      return HttpException(HttpCode.TIMEOUT, e.message);
    } on SocketException catch (e) {
      print('Error: $e');
      return HttpException(HttpCode.NOT_FOUND, e.message);
    } on Error catch (e) {
      print('Error: $e');
      return HttpException(HttpCode.BAD_REQUEST, e.stackTrace.toString());
    }
  }

  static post(String url, Map params, {header = HEADER}) async {
    try {
      final body = jsonEncode(params);
      print('request:: (post) $url, body: $body');
      final response = await client.post(
          url, headers: header, body: body
      ).timeout(TIMEOUT_DURATION);
      print('response:: code: ${response.statusCode}, body: ${response.body}');
      return response;
    } on TimeoutException catch (e) {
      print('Timeout $e');
      return HttpException(HttpCode.TIMEOUT, e.message);
    } on SocketException catch (e) {
      print('Error: $e');
      return HttpException(HttpCode.NOT_FOUND, e.message);
    } on Error catch (e) {
      print('Error: $e');
      return HttpException(HttpCode.BAD_REQUEST, e.stackTrace.toString());
    }
  }

  static closeConnection() {
    client.close();
  }

  static _constructQueryUrl(String url, Map params) {
    if(params == null || params.isEmpty) return url;
    
    String query = '';
    params.forEach((key, value) {
      query += '$key=$value&';
    });
    query = query.substring(0, query.length - 1);

    return '$url?$query';
  }
}

class HttpException {
  int statusCode;
  String message;

  HttpException(this.statusCode, this.message);
}

class HttpCode {
  static const OK = 200;
  static const NOT_FOUND = 404;
  static const BAD_REQUEST = 500;
  static const TIMEOUT = 501;
}

class PickingStatus {
  static const NOT_STARTED = 0;
  static const DONE = 1;
  static const WORKING = 2;
}

class PickingCheckStatus {
  static const NOT_PICKED = 200;
  static const PICKED = 1001;
  static const NOT_AVAILABLE = 1002;
  static const OVER_REGISTRATION_QUANTITY = 1005;
}

class PackingStatus {
  static const NOT_STARTED = 0;
  static const DONE = 1;
  static const WORKING = 2;
}

class PackingQrCodeStatus {
  static const SUCCESS = 200;
  static const REGISTERED = 1003;
  static const NOT_ISSUED = 1004;
}