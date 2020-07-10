import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/home/history/history_type.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

import 'common/app_icons.dart';

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

  _cardBodyBuilder() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    String deliveryTime = historyType == HistoryType.PLANNING? orderItem.endingTime
        : historyType == HistoryType.DELIVERED? orderItem.deliveredTime
        : orderItem.stockoutReportDate;
    if(deliveryTime == null) deliveryTime = '1970-01-01 00:00';
    final deliveryDate = Converter.toDateTime(deliveryTime);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                historyType == HistoryType.PLANNING || historyType == HistoryType.DELIVERED
                    ? locale.txtDeliveryNumber : locale.txtOrderNumber,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.color99000000,
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(orderItem.packageManageNo.toString(), style: TextStyle(fontSize: 14,),),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                color: Colors.black12,
                height: 1.2,
                width: MediaQuery.of(context).size.width - 90,
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
              Text(
                historyType == HistoryType.PLANNING
                    ? locale.txtWorkFinishingTime : historyType == HistoryType.DELIVERED
                    ? locale.txtShippingTimeOfTheDay : locale.txtStockoutTime,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.color99000000,
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 16),),
              Text(
                '${deliveryDate.hour}:${deliveryDate.minute}',
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
      margin: new EdgeInsets.symmetric(vertical: 6.0, horizontal: 13),
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