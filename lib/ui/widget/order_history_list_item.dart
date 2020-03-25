import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/home/history/order_list_history.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class OrderHistoryListItem extends StatelessWidget {

  final BuildContext context;
  final OrderItem orderItem;
  final HistoryType historyType;
  final Function onPressed;

  OrderHistoryListItem({
    Key key,
    @required this.context,
    @required this.orderItem,
    @required this.historyType,
    this.onPressed
  }): super(key: key);

  Container _cardBodyBuilder() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                historyType == HistoryType.PLANNING || historyType == HistoryType.COMPLETE
                    ? locale.txtDeliveryNumber : locale.txtOrderNumber,
                style: TextStyle(fontSize: 14,),
              ),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(orderItem.orderNo.toString(), style: TextStyle(fontSize: 14,),),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                color: Colors.black12,
                height: 1,
                width: MediaQuery.of(context).size.width - 100,
              ),
              Spacer(),
              Icon(Icons.keyboard_arrow_right, color: Colors.lightBlue,),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                historyType == HistoryType.PLANNING
                    ? locale.txtWorkFinishingTime : historyType == HistoryType.COMPLETE
                    ? locale.txtShippingTimeOfTheDay : locale.txtStockoutTime,
                style: TextStyle(fontSize: 14,),
              ),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(
                historyType == HistoryType.PLANNING? orderItem.workCompletionTime :
                historyType == HistoryType.COMPLETE? orderItem.deliveryTime :
                orderItem.cancellationTime,
                style: TextStyle(fontSize: 14,),
              ),
            ],
          ),
        ],
      )
    );
  }

  Card _makeCard(context) {
    return Card(
      margin: new EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: _cardBodyBuilder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: InkWell(
        child: _makeCard(context),
      ),
      onTap: this.onPressed,
    );
  }
}