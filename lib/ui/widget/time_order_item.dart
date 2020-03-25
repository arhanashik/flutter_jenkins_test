import 'package:flutter/material.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/orderlist/order_list.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';

class TimeOrderItem extends StatelessWidget {

  final BuildContext context;
  final TimeOrder timeOrder;

  TimeOrderItem(
      {Key key, @required this.context, @required this.timeOrder}
  ): super(key: key);

  _itemHeaderBuilder() {
//    final dateTime = DateTime.parse(timeOrder.scheduledDeliveryDateTime);
    final deliveryTime = timeOrder.scheduledDeliveryDateTime.substring(
        timeOrder.scheduledDeliveryDateTime.lastIndexOf(" ")
    );

    return Container(
      height: 32,
      width: MediaQuery.of(context).size.width - 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10)
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Row(
          children: <Widget>[
            Text(
              deliveryTime,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, top: 4),
              child: Text(
                '発送分',
                style: TextStyle(
                    fontSize: 14, color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _itemBodyBuilder() {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width - 16,
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)
          )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 20),),
          Text(
            "末完了",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10),),
          Text(
            timeOrder.incompleteOrderCount.toString(),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.colorRed
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5),),
          Text(
            "件",
            style: TextStyle(
                fontSize: 14, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5),),
          Text(
            "/",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5),),
          Text(
            "注文",
            style: TextStyle(
                fontSize: 14, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5),),
          Text(
            timeOrder.orderCount.toString(),
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5),),
          Text(
            "件",
            style: TextStyle(
                fontSize: 14, color: Colors.black
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10),),
          Container(
            height: 18,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.colorB3DAFF,
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Text(
              "${timeOrder.totalProductCount}個",
              style: TextStyle(
                  fontSize: 12, color: Colors.black
              ),
            ),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_right, color: AppColors.colorBlue,),
          Padding(padding: EdgeInsets.only(right: 16),),
        ],
      ),
    );
  }

  Container _itemCompletedOrderBuilder() {
    final deliveryTime = timeOrder.scheduledDeliveryDateTime.substring(
        timeOrder.scheduledDeliveryDateTime.lastIndexOf(" ")
    );

    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      child: Row(
        children: <Widget>[
          Text(
            deliveryTime,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 4),
            child: Text(
              '発送分',
              style: TextStyle(
                  fontSize: 14, color: Colors.white
              ),
            ),
          ),
          Spacer(),
          Text(
            '対応完了',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return timeOrder.incompleteOrderCount == 0? _itemCompletedOrderBuilder() : InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OrderList(timeOrder: timeOrder,)
      )),
      child: Container(
        child: Column(
          children: <Widget>[
            _itemHeaderBuilder(),
            _itemBodyBuilder()
          ],

        ),
      ),
    );
  }
}