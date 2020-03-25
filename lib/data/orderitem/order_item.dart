
import 'package:o2o/util/lib/remote/http_util.dart';

class OrderItem {
  final int orderNo;
  final int productCount;
  final int totalPrice;
  int pickingStatus;
  final String lockedName;
  final String workCompletionTime;
  String deliveryTime;
  final String cancellationTime;

  OrderItem._({
    this.orderNo,
    this.productCount,
    this.totalPrice,
    this.pickingStatus,
    this.lockedName,
    this.workCompletionTime,
    this.deliveryTime,
    this.cancellationTime,
  });

  OrderItem({
    this.orderNo,
    this.productCount,
    this.totalPrice,
    this.pickingStatus,
    this.lockedName,
    this.workCompletionTime,
    this.deliveryTime,
    this.cancellationTime,
  });

  isUnderWork(_myDeviceName) {
    return this.lockedName != null
        && this.lockedName.isNotEmpty
        && this.lockedName != _myDeviceName;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return new OrderItem._(
      orderNo: json['orderNo'],
      productCount: json['productCount'],
      totalPrice: json['totalPrice'],
      pickingStatus: json['pickingStatus'],
      lockedName: json['lockedName'],
      workCompletionTime: json['workCompletionTime'],
      deliveryTime: json['deliveryTime'],
      cancellationTime: json['cancellationTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderNo': orderNo,
    'productCount': productCount,
    'totalPrice': totalPrice,
    'pickingStatus': pickingStatus,
    'lockedName': lockedName,
    'workCompletionTime': workCompletionTime,
    'deliveryTime': deliveryTime,
    'cancellationTime': cancellationTime,
  };

  static dummyOrderItems() {
    return [
      OrderItem(
        orderNo: 134534534563463534,
        productCount: 5,
        totalPrice: 1000,
        pickingStatus: PickingStatus.WORKING,
        lockedName: '0123',
        workCompletionTime: '12:45',
        deliveryTime: '10:50',
        cancellationTime: '12:50',
      ),
      OrderItem(
        orderNo: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.NOT_STARTED,
        lockedName: '',
        workCompletionTime: '12:45',
        deliveryTime: '11:00',
        cancellationTime: '12:45',
      ),
      OrderItem(
        orderNo: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.DONE,
        lockedName: '0123',
        workCompletionTime: '12:45',
        deliveryTime: '11:00',
        cancellationTime: '12:45',
      ),
      OrderItem(
        orderNo: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.DONE,
        lockedName: '',
        workCompletionTime: '12:45',
        deliveryTime: '11:00',
        cancellationTime: '12:45',
      ),
      OrderItem(
        orderNo: 324353532,
        productCount: 3,
        totalPrice: 2000,
        pickingStatus: PickingStatus.NOT_STARTED,
        lockedName: '',
        workCompletionTime: '12:45',
        deliveryTime: '11:00',
        cancellationTime: '12:45',
      ),
    ];
  }
}