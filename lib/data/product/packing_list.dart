import 'package:o2o/data/product/product_entity.dart';

/// Created by mdhasnain on 24 Mar, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. Getting the response from the packing product list on packing step 1
/// 2. 
/// 3.

class PackingList {
  int orderId;
  int totalPrice;
  String appointedDeliveringTime;
  List products;

  PackingList._({
    this.orderId,
    this.totalPrice,
    this.appointedDeliveringTime,
    this.products
  });

  PackingList({
    this.orderId,
    this.totalPrice,
    this.appointedDeliveringTime,
    this.products
  });

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return json == null? null : PackingList(
      orderId: json['orderId'],
      totalPrice: json['totalAmount'],
      appointedDeliveringTime: json['appointedDeliveringTime'],
      products: json['products'].map(
          (data) => ProductEntity.fromJson(data)
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'totalPrice': totalPrice,
    'appointedDeliveringTime': appointedDeliveringTime,
    'products': products.map((product) => product.toJson()),
  };

  static dummyPackingList() => PackingList(
    orderId: 1234,
    totalPrice: 3450,
    appointedDeliveringTime: "2020-03-24 15:15",
    products: ProductEntity.dummyProducts(),
  );
}