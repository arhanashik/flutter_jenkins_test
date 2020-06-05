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
  final List timeOrderSummaryList;

  TimeOrderListItem._({
    this.date,
    this.timeOrderSummaryList
  });

  TimeOrderListItem({
    this.date,
    this.timeOrderSummaryList
  });

  factory TimeOrderListItem.fromJson(Map<String, dynamic> jsonData) {
    return new TimeOrderListItem._(
      date: jsonData['date'],
      timeOrderSummaryList: jsonData['timeOrderSummaryList'].map(
              (data) => TimeOrder.fromJson(data)
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'timeOrderSummaryList': timeOrderSummaryList.map((data) => data.toJson()),
  };

  static dummyTimeOrderList() {
    return [
      TimeOrderListItem(
          date: "2020-02-12", timeOrderSummaryList: TimeOrder.dummyTimeOrderList()
      ),
      TimeOrderListItem(
          date: "2020-02-13", timeOrderSummaryList: TimeOrder.dummyTimeOrderList()
      ),
    ];
  }
}