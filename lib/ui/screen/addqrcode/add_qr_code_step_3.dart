import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';

class AddQrCodeStep3 extends StatefulWidget {

  AddQrCodeStep3(this.orderItem, this.qrCodes, this.onPreviousScreen, this.onNextScreen);
  final OrderItem orderItem;
  final List<String> qrCodes;
  final Function onPreviousScreen;
  final Function onNextScreen;

  @override
  _AddQrCodeStep3State createState() => _AddQrCodeStep3State(
      orderItem, HashSet.from(qrCodes), onPreviousScreen, onNextScreen
  );
}

class _AddQrCodeStep3State extends BaseState<AddQrCodeStep3> {

  _AddQrCodeStep3State(this._orderItem, this._qrCodes, this._onPreviousScreen, this._onNextScreen);
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

  _confirmAndGoToNext() {
    ConfirmationDialog(
      context,
      locale.txtConfirmChange,
      locale.msgConfirmChange,
      locale.txtDone,
      () => _onNextScreen(),
    ).show();
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
            onPressed: () => _confirmAndGoToNext(),
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
              _textBuilder('修正が必要な荷札QRコード', Colors.black, FontWeight.w500),
              _textBuilder(_qrCodes.join('\n'), Colors.black, FontWeight.w500),
              _textBuilder('${locale.txtBaggageManagementNumber}: 4444', Colors.blue, FontWeight.bold),
              _textBuilder('${locale.txtNumberOfPieces}: ${_orderItem.productCount}', Colors.blue, FontWeight.bold),
            ],
          ),
          _buildControlBtn(),
        ],
      ),
    );
  }

}