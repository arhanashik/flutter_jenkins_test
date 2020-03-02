class TimeOrder {
  final String scheduledDeliveryDateTime;
  final int orderCount;
  final int incompleteOrderCount;
  final int totalProductCount;

  TimeOrder._({
    this.scheduledDeliveryDateTime,
    this.orderCount,
    this.incompleteOrderCount,
    this.totalProductCount
  });

  TimeOrder({
    this.scheduledDeliveryDateTime,
    this.orderCount,
    this.incompleteOrderCount,
    this.totalProductCount
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
}