import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class OrderListItem extends StatelessWidget {

  final BuildContext context;
  final OrderItem orderItem;
  final Function onPressed;

  OrderListItem({
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
              Text(orderItem.orderId.toString(), style: TextStyle(fontSize: 16,),),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                color: Colors.black26,
                height: 1,
                width: MediaQuery.of(context).size.width - 94,
              ),
              Spacer(),
              AppIcons.loadIcon(
                  AppIcons.icArrowRight,
                  size: 18.0,
                  color: AppColors.colorBlue
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(locale.txtProductCount, style: TextStyle(fontSize: 14,),),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  orderItem.productCount.toString(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorBlueDark
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2, top: 2),
                child: Text(
                  locale.txtPiece,
                  style: TextStyle(
                      fontSize: 12, color: Colors.black
                  ),
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
      margin: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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