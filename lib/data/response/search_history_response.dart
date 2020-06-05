import 'package:o2o/data/orderitem/order_item.dart';

/// Created by mdhasnain on 07 May, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3. 

class SearchHistoryResponse  {
  final String date;
  final List searchOrderList;

  SearchHistoryResponse._({this.date, this.searchOrderList});

  factory SearchHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SearchHistoryResponse._(
      date: json['date'],
      searchOrderList: json['searchOrderList'].map(
              (data) => OrderItem.fromJson(data)
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'resultCode': date,
    'searchOrderList': searchOrderList,
  };
}