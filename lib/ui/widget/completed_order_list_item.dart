import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';

class CompletedOrderListItem extends StatelessWidget {

  final BuildContext context;
  final OrderItem orderItem;
  final Function onPressed;

  CompletedOrderListItem({
    Key key,
    @required this.context,
    @required this.orderItem,
    this.onPressed
  }): super(key: key);

  Container _cardBodyBuilder() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(locale.txtOrderNumber, style: TextStyle(fontSize: 14,),),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(orderItem.orderNo.toString(), style: TextStyle(fontSize: 14,),),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                color: Colors.black,
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
              Text(locale.txtProductCount, style: TextStyle(fontSize: 14,),),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(
                orderItem.productCount.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 5),),
              Text(
                locale.txtPiece,
                style: TextStyle(
                    fontSize: 14, color: Colors.black
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Card _makeCard(context) {
    return Card(
      margin: new EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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