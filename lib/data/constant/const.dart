/// Created by mdhasnain on 21 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class AppConst {
  static const _BASE_URL = 'http://128.168.76.221:8080/api/v1';

  static const GET_INFO = '$_BASE_URL/store/info';

  static const REGISTER_IMEI = '$_BASE_URL/timeorder/list';
  static const GET_TIME_ORDER = '$_BASE_URL/timeorder/list';
  static const GET_TIME_ORDER_HISTORY = '$_BASE_URL/timeorderhistory/list';

  static const GET_ORDER_LIST = '$_BASE_URL/orderlist/list';

  static const UPDATE_PICKING_STATUS = '$_BASE_URL/picking/status/update';
  static const GET_PICKING_LIST = '$_BASE_URL/picking/list';
  static const CHECK_PICKED_ITEM = '$_BASE_URL/picking/details';
  static const UPDATE_PICKING_COUNT = '$_BASE_URL/picking/product/status/update';

  static const UPDATE_PACKING_STATUS = '$_BASE_URL/packing/status/update';
  static const UPDATE_RECEIPT_NUMBER = '$_BASE_URL/packing/receipt_no/update';
  static const CHECK_PACKING_QR_CODE = '$_BASE_URL/packing/qr_code/judge';

  static const WEEKDAYS = const ["月","火","水","木","金","土","日",];

  static const NO_IMAGE_URL = 'https://via.placeholder.com/150/999999/fff?text=NO+IMAGE';
  static const NO_IMAGE_URL_LARGE = 'https://via.placeholder.com/240/999999/fff?text=NO+IMAGE';
}

class PickingStatus {
  static const NOT_STARTED = 0;
  static const DONE = 1;
  static const WORKING = 2;
}

class PickingCheckStatus {
  static const NOT_PICKED = 0;
  static const PICKED = 1;
  static const NOT_AVAILABLE = 2;
}

class PackingStatus {
  static const NOT_STARTED = 0;
  static const DONE = 1;
  static const WORKING = 2;
}

class PackingQrCodeStatus {
  static const SUCCESS = 0;
  static const REGISTERED = 1;
  static const NOT_ISSUED = 2;
}