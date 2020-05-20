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
  static const _DEV_SERVER = 'http://128.168.76.221:8080';
  static const _BASE_URL = '$_DEV_SERVER/api/v1';

  static const LOGIN = '$_BASE_URL/login';
  static const UPDATE_FCM_TOKEN = '$_BASE_URL/firebase/token/update';
  static const REGISTER_IMEI = '$_BASE_URL/timeorder/list';

  static const GET_TIME_ORDER = '$_BASE_URL/timeorder/list';

  static const GET_ORDER_LIST = '$_BASE_URL/orderlist/list';

  static const UPDATE_PICKING_STATUS = '$_BASE_URL/picking/status/update';
  static const GET_PICKING_LIST = '$_BASE_URL/picking/list';
  static const CHECK_PICKED_ITEM = '$_BASE_URL/picking/details';
  static const UPDATE_PICKING_COUNT = '$_BASE_URL/picking/product/status/update';
  static const CHECK_STOCK_OUT_STATUS = '$_BASE_URL/stockout/info/update';

  static const UPDATE_PACKING_STATUS = '$_BASE_URL/packing/status/update';
  static const GET_PACKING_LIST = '$_BASE_URL/packing/list';
  static const UPDATE_RECEIPT_NUMBER = '$_BASE_URL/packing/receipt_no/update';
  static const CHECK_PACKING_QR_CODE = '$_BASE_URL/packing/qr_code/judge';
  static const UPDATE_PACKING_QR_CODE = '$_BASE_URL/packing/qrCode/update';

  static const GET_HISTORY_LIST_BEFORE_SHIPPING = '$_BASE_URL/workHistory/beforeShippingList';
  static const GET_HISTORY_LIST_DELIVERED = '$_BASE_URL/workHistory/deliveredlist';
  static const GET_HISTORY_LIST_STOCK_OUT = '$_BASE_URL/workHistory/stockoutlist';

  static const GET_HISTORY_LIST_READY_TO_SHIP = '$_BASE_URL/workHistory/readyToShipList';
  static const GET_HISTORY_LIST_SPECIFIED_TIME = '$_BASE_URL/workHistory/specifiedTimeList';
  static const GET_HISTORY_LIST_SPECIFIED_TIME_STOCK_OUT = '$_BASE_URL/workHistory/specifiedtimestockoutlist';

  static const GET_HISTORY_DETAILS = '$_BASE_URL/workHistory/historyDetails';
  static const GET_HISTORY_STOCK_OUT_DETAILS = '$_BASE_URL/workHistory/historyStockoutDetails';

  static const SEARCH_HISTORY_BY_JAN_CODE = '$_BASE_URL/workHistory/searchJanCode';
  static const SEARCH_HISTORY_BY_QR_CODE = '$_BASE_URL/workHistory/searchQrCode';

  static const ADD_QR_CODE_ON_HISTORY = '$_BASE_URL/workHistory/addQrCodes';
  static const DELETE_QR_CODE_FROM_HISTORY = '$_BASE_URL/workHistory/deleteQrCode';

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
  static const INVALID_PARAM = 2002;
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
  static const NOT_AVAILABLE_IN_THE_ORDER = 1007;
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

class JANCodeScanFlag {
  static const SCAN = 0;
  static const MANUAL = 1;
}

class SearchOrderFlag {
  static const DELIVERED = 1011;
  static const PACKING_COMPLETE = 1010;
  static const MISSING = 1008;
}

class Params {
  static const SERIAL = 'serial';
  static const TOKEN = 'token';
  static const DEVICE_NAME = 'deviceName';
  static const STORE_NAME = 'storeName';
  static const CODE = 'code';
  static const MSG = 'msg';
  static const DATA = 'data';
  static const DELIVERY_DATE_TIME = 'deliveryDateTime';
  static const ORDER_ID = 'orderId';
  static const STATUS = 'status';
  static const QR_CODE = 'qrCode';
  static const BAR_CODE = 'barcode';
  static const JAN_CODE = 'janCode';
  static const PICKING_COUNT = 'pickingCount';
  static const RECEIPT_NO = 'receiptNo';
  static const PRIMARY_QR_CODE = 'primaryQrCode';
  static const OTHER_QR_CODE = 'otherQrCode';
  static const QR_CODE_LIST = 'qrCodeList';
  static const JAN_CODE_LIST = 'janCodeList';
  static const FLAG = 'flag';
}

class TransitStatus {
  static const PICKING_DONE = 1;
  static const STOCK_OUT = 3;
  static const PACKING_DONE = 2;
}