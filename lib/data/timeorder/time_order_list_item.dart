import 'package:o2o/data/timeorder/time_order.dart';

/// Created by mdhasnain on 21 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class TimeOrderListItem {
  final String date;
  final List timeOrderList;

  TimeOrderListItem._({
    this.date,
    this.timeOrderList
  });

  TimeOrderListItem({
    this.date,
    this.timeOrderList
  });

  factory TimeOrderListItem.fromJson(Map<String, dynamic> jsonData) {
    return new TimeOrderListItem._(
      date: jsonData['date'],
      timeOrderList: jsonData['timeOrderSummaryList'].map(
              (data) => TimeOrder.fromJson(data)
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'timeOrderSummaryList': timeOrderList.map((data) => data.toJson()),
  };
}