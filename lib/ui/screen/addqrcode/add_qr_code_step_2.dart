import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

class AddQrCodeStep2 extends StatefulWidget {

  AddQrCodeStep2(this.orderItem, this.qrCodes, this.onPreviousScreen, this.onNextScreen);
  final OrderItem orderItem;
  final List<String> qrCodes;
  final Function onPreviousScreen;
  final Function onNextScreen;

  @override
  _AddQrCodeStep2State createState() => _AddQrCodeStep2State(
      orderItem, HashSet.from(qrCodes), onPreviousScreen, onNextScreen
  );
}

class _AddQrCodeStep2State extends BaseState<AddQrCodeStep2> {

  _AddQrCodeStep2State(this._orderItem, this._qrCodes, this._onPreviousScreen, this._onNextScreen);
  final OrderItem _orderItem;
  final HashSet<String> _qrCodes;
  final Function _onPreviousScreen;
  final Function _onNextScreen;

  _textBuilder(text, color, fontWeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: fontWeight),
      ),
    );
  }

  _msgBuilder() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: Text('記載イメージのイラスト'),
    );
  }

  _buildControlBtn() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GradientButton(
            text: locale.txtGoBack,
            onPressed: () => _onPreviousScreen(),
            gradient: AppColors.darkGradient,
          ),
          GradientButton(
            text: locale.txtCompleteShippingPreparation,
            onPressed: () => _onNextScreen(),
            showIcon: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Stack (
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          ListView(
            children: <Widget>[
              _msgBuilder(),
              _textBuilder('${locale.txtOrderNumber}: ${_orderItem.orderId}', Colors.black, FontWeight.w500),
              _textBuilder('①${locale.txtShippingPlanTime}: 13:00', Colors.blue, FontWeight.bold),
              _textBuilder('②${locale.txtBaggageManagementNumber}: 4444', Colors.blue, FontWeight.bold),
              _textBuilder('③${locale.txtNumberOfPieces}: ${_orderItem.productCount}', Colors.blue, FontWeight.bold),
              _textBuilder('${locale.txtQRScannedLabeledCount}', Colors.black, FontWeight.w500),
              _textBuilder(_qrCodes.join('\n'), Colors.black, FontWeight.w500),
            ],
          ),
          _buildControlBtn(),
        ],
      ),
    );
  }

}