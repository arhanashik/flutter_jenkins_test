class TimeOrder {
  final String scheduledDeliveryDateTime;
  final int orderCount;
  final int incompleteOrderCount;
  final int totalProductCount;

  TimeOrder._({
    this.scheduledDeliveryDateTime,
    this.orderCount,
    this.incompleteOrderCount,
    this.totalProductCount,
  });

  TimeOrder({
    this.scheduledDeliveryDateTime,
    this.orderCount,
    this.incompleteOrderCount,
    this.totalProductCount,
  });

  factory TimeOrder.fromJson(Map<String, dynamic> json) {
    return new TimeOrder._(
      scheduledDeliveryDateTime: json['scheduledDeliveryDateTime'],
      orderCount: json['orderCount'],
      incompleteOrderCount: json['incompleteOrderCount'],
      totalProductCount: json['totalProductCount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'scheduledDeliveryDateTime': scheduledDeliveryDateTime,
    'orderCount': orderCount,
    'incompleteOrderCount': incompleteOrderCount,
    'totalProductCount': totalProductCount,
  };

  static dummyTimeOrderList() {
    return [
      TimeOrder(
        scheduledDeliveryDateTime: "2020-02-12 11:00",
        orderCount: 3,
        incompleteOrderCount: 2,
        totalProductCount: 5,
      ),
      TimeOrder(
        scheduledDeliveryDateTime: "2020-02-12 12:00",
        orderCount: 3,
        incompleteOrderCount: 1,
        totalProductCount: 4,
      ),
      TimeOrder(
        scheduledDeliveryDateTime: "2020-02-12 11:20",
        orderCount: 3,
        incompleteOrderCount: 0,
        totalProductCount: 5,
      ),
    ];
  }
}