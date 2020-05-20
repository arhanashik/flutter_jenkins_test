
import 'package:o2o/util/lib/remote/http_util.dart';

class OrderItem {
  final int orderId;
  final int productCount;
  final int totalPrice;
  int pickingStatus;
  final String lockedName;
  final String endingTime;
  String deliveryTime;
  final String stockoutReportDate;
  final int packageManageNo;
  final String deliveredTime;
  final int flag;

  OrderItem._({
    this.orderId,
    this.productCount,
    this.totalPrice,
    this.pickingStatus,
    this.lockedName,
    this.endingTime,
    this.deliveryTime,
    this.stockoutReportDate,
    this.packageManageNo,
    this.deliveredTime,
    this.flag,
  });

  OrderItem({
    this.orderId,
    this.productCount,
    this.totalPrice,
    this.pickingStatus,
    this.lockedName,
    this.endingTime,
    this.deliveryTime,
    this.stockoutReportDate,
    this.packageManageNo,
    this.deliveredTime,
    this.flag,
  });

  isUnderWork(_myDeviceName) {
    return this.lockedName != null
        && this.lockedName.isNotEmpty
        && this.lockedName != _myDeviceName;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return new OrderItem._(
      orderId: json['orderId'],
      productCount: json['productCount'],
      totalPrice: json['totalPrice'],
      pickingStatus: json['pickingStatus'],
      lockedName: json['lockedName'],
      endingTime: json['endingTime'],
      deliveryTime: json['appointedDeliveringTime'],
      stockoutReportDate: json['stockoutReportDate'],
      packageManageNo: json['packageManageNo'],
      deliveredTime: json['deliveredTime'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'productCount': productCount,
    'totalPrice': totalPrice,
    'pickingStatus': pickingStatus,
    'lockedName': lockedName,
    'endingTime': endingTime,
    'appointedDeliveringTime': deliveryTime,
    'stockoutReportDate': stockoutReportDate,
    'packageManageNo': packageManageNo,
    'deliveredTime': deliveredTime,
    'flag': flag,
  };

  static dummyOrderItems() {
    return [
      OrderItem(
        orderId: 134534534563463534,
        productCount: 5,
        totalPrice: 1000,
        pickingStatus: PickingStatus.WORKING,
        lockedName: '0123',
        endingTime: '12:45',
        deliveryTime: '10:50',
        stockoutReportDate: '12:50',
        packageManageNo: 123,
        deliveredTime: '12:50',
        flag: 1011,
      ),
      OrderItem(
        orderId: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.NOT_STARTED,
        lockedName: '',
        endingTime: '12:45',
        deliveryTime: '11:00',
        stockoutReportDate: '12:45',
        packageManageNo: 123,
        deliveredTime: '12:50',
        flag: 1010,
      ),
      OrderItem(
        orderId: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.DONE,
        lockedName: '0123',
        endingTime: '12:45',
        deliveryTime: '11:00',
        stockoutReportDate: '12:45',
        packageManageNo: 123,
        deliveredTime: '12:50',
        flag: 1008,
      ),
      OrderItem(
        orderId: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.DONE,
        lockedName: '',
        endingTime: '12:45',
        deliveryTime: '11:00',
        stockoutReportDate: '12:45',
        packageManageNo: 123,
        deliveredTime: '12:50',
        flag: 1011,
      ),
      OrderItem(
        orderId: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.NOT_STARTED,
        lockedName: '',
        endingTime: '12:45',
        deliveryTime: '11:00',
        stockoutReportDate: '12:45',
        packageManageNo: 123,
        deliveredTime: '12:50',
        flag: 1010,
      ),
    ];
  }
}