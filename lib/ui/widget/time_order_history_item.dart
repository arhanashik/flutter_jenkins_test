import 'package:flutter/material.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/home/history/history_type.dart';
import 'package:o2o/ui/screen/orderlisthistory/order_list_history.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class TimeOrderHistoryItem extends StatelessWidget {

  final BuildContext context;
  final TimeOrder timeOrder;
  final HistoryType historyType;

  TimeOrderHistoryItem(
      {Key key, @required this.context, @required this.timeOrder, @required this.historyType}
  ): super(key: key);

  Container _itemHeaderBuilder() {
    String deliveryTime = '';
    deliveryTime = timeOrder.scheduledDeliveryDateTime.substring(
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
        padding: EdgeInsets.symmetric(horizontal: 13),
        child: Row(
          children: <Widget>[
            Text(
              deliveryTime,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, top: 2.5),
              child: Text(
                '発送分',
                style: TextStyle(
                    fontSize: 12, color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _itemBodyBuilder() {
    O2OLocalizations locale = O2OLocalizations.of(context);

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
          Padding(padding: EdgeInsets.only(left: 18),),
          Text(
            locale.txtOrderQuantity, style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          Padding(
            padding: EdgeInsets.only(left: 3, bottom: 3.5, right: 3),
            child: Text(
              timeOrder.orderCount.toString(),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.colorBlueDark
              ),
            ),
          ),
          Text(
            "件", style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_right, color: AppColors.colorBlue,),
          Padding(padding: EdgeInsets.only(right: 16),),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    String title = '12月10日 (金) 13:00 発送分';

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OrderListHistoryScreen(timeOrder, historyType)
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