
import 'package:o2o/data/product/product_entity.dart';

class OrderHistoryDetails {
  final int orderId;
  final String endingTime;
  final String appointedDeliveringTime;
  List qrCodes;
  final int qrCodeCount;
  int receiptNo;
  String lockedName;
  List products = List();
  final int baggageControlNumber;

  OrderHistoryDetails._({
    this.orderId,
    this.endingTime,
    this.appointedDeliveringTime,
    this.qrCodes,
    this.qrCodeCount,
    this.receiptNo,
    this.lockedName,
    this.products,
    this.baggageControlNumber,
  });

  OrderHistoryDetails({
    this.orderId = 0,
    this.endingTime = '',
    this.appointedDeliveringTime = '',
    this.qrCodes = const [],
    this.qrCodeCount = 0,
    this.receiptNo = 0,
    this.lockedName = '',
    this.products = const [],
    this.baggageControlNumber = 0,
  });

  factory OrderHistoryDetails.fromJson(Map<String, dynamic> json) {
    return new OrderHistoryDetails._(
      orderId: json['orderId'],
      endingTime: json['endingTime'],
      appointedDeliveringTime: json['appointedDeliveringTime'],
      qrCodes: json['qrCodes'].map((data) => data.toString(),).toList(),
      qrCodeCount: json['qrCodeCount'],
      receiptNo: json['receiptNo'],
      lockedName: json['lockedName'],
      products: json['products'].map(
              (data) => ProductEntity.fromJson(data)
      ).toList(),
      baggageControlNumber: json['baggageControlNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'endingTime': endingTime,
    'appointedDeliveringTime': appointedDeliveringTime,
    'qrCodes': qrCodes,
    'qrCodeCount': qrCodeCount,
    'receiptNo': receiptNo,
    'lockedName': lockedName,
    'products': products,
    'baggageControlNumber': baggageControlNumber,
  };

  static dummyOrderHistoryDetailsResponse() {
    return OrderHistoryDetails(
      orderId: 1,
      endingTime: '12:45',
      appointedDeliveringTime: '12:45',
      qrCodes: ['111-222-333-444', '333-444-555-666', '666-777-888-999'],
      qrCodeCount: 3,
      receiptNo: 1234,
      lockedName: '2223',
      products: ProductEntity.dummyProducts(),
      baggageControlNumber: 12345,
    );
  }
}