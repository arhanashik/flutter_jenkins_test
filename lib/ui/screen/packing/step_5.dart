import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_5_qr_code_list_dialog.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/helper/common.dart';

class Step5Screen extends StatefulWidget {

  Step5Screen(
      this._orderItem,
      this._qrCodes,
      this._onPrevScreen,
      this._onCompletion
  );
  final OrderItem _orderItem;
  final LinkedHashSet<String> _qrCodes;
  final Function _onPrevScreen;
  final Function _onCompletion;

  @override
  _Step5ScreenState createState() => _Step5ScreenState(
      _orderItem, _qrCodes, _onPrevScreen, _onCompletion
  );
}

class _Step5ScreenState extends BaseState<Step5Screen> {

  _Step5ScreenState(
      this._orderItem,
      this._qrCodes,
      this._onPrevScreen,
      this._onCompletion
  );
  final OrderItem _orderItem;
  final LinkedHashSet<String> _qrCodes;
  final Function _onPrevScreen;
  final Function _onCompletion;

  bool _primaryQrCodeChanged = false;
  bool _qrCodeChanged = false;

  _buildQrCodeDeletedWarning() {
    return Visibility(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: Text(
          locale.warningUpdateLabelInfo,
          style: TextStyle(
              color: AppColors.colorAccent,
              fontSize: 12.0,
              fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
      ),
      visible: _qrCodeChanged || _primaryQrCodeChanged,
    );
  }

  _buildQrCodeListViewer() {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        margin: EdgeInsets.only(left: 36.0, top: 16.0, right: 36.0, bottom: 4.0),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('読み取った荷札QRコードを確認する', style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500
            ),),
            Icon(Icons.arrow_forward_ios, size: 18.0,)
          ],
        ),
      ),
      onTap: () => _showQrCodeList(),
    );
  }

  _buildInstruction() {
    String primaryQrCode = _qrCodes.isEmpty? '12121212' : _qrCodes.toList()[0];
    String primaryQrCodeLast4Digit = primaryQrCode.substring(primaryQrCode.length-4);

    final deliveryDate = Converter.toDateTime(_orderItem.deliveryTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            AppImages.loadSizedImage(AppImages.icDigit1Url, width: 36.0, height: 36.0),
            Padding(
              padding: EdgeInsets.only(left: 10,),
              child: Text('の箇所に', style: TextStyle(
                  color: Colors.black, fontSize: 14,
              ),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('${deliveryDate.hour}:${deliveryDate.minute}',
                style: TextStyle(
                  color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
              ),),
            ),
            Text('を記入してください。', style: TextStyle(
                color: Colors.black, fontSize: 14,
            ),),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 5),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.loadSizedImage(_primaryQrCodeChanged? AppImages.icDigit2RedUrl : AppImages.icDigit2Url, width: 36.0, height: 36.0),
            Padding(
              padding: EdgeInsets.only(left: 10,),
              child: Text('の箇所に', style: TextStyle(
                  color: Colors.black, fontSize: 14,
              ),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                primaryQrCodeLast4Digit,
                style: TextStyle(
                  color: _primaryQrCodeChanged? Colors.redAccent : Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
                ),
              ),
            ),
            Text('を記入してください。', style: TextStyle(
                color: Colors.black, fontSize: 14,
            ),),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 5),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.loadSizedImage(
                _primaryQrCodeChanged || _qrCodeChanged? AppImages.icDigit3RedUrl : AppImages.icDigit3Url, width: 36.0, height: 36.0
            ),
            Padding(
              padding: EdgeInsets.only(left: 10,),
              child: Text('の箇所に', style: TextStyle(
                  color: Colors.black, fontSize: 14,
              ),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('${locale.txtQuantity}/${_qrCodes.length}',
                style: TextStyle(color: _primaryQrCodeChanged || _qrCodeChanged
                      ? Colors.redAccent : Colors.blue,
                  fontSize: 18, fontWeight: FontWeight.bold
              ),),
            ),
            Text('を記入してください。', style: TextStyle(
                color: Colors.black, fontSize: 14,
            ),),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8.0),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('＊荷物が1つの場合、', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
            AppImages.icDigit3,
            Text(' には1/1と記入してください。', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 2.5),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('＊荷物が2つの場合の', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
            AppImages.icDigit3,
            Text(' の個数の記入例は以下です。', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 5),
          child: Text('1個目の荷物：　　1/2', style: TextStyle(
            color: Colors.black, fontSize: 12,
          ),),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 5),
          child: Text('2個目の荷物：　　2/2', style: TextStyle(
            color: Colors.black, fontSize: 12,
          ),),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.keyboard_arrow_down, size: 64.0, color: Colors.grey,)
          ],
        )
      ],
    );
  }

  _buildMessage() {
    return Container(
      height: 100,
      color: Colors.black12,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        margin: EdgeInsets.all(13.0),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder('ラベルは記入が終わりましたら、\n',),
                CommonWidget.textSpanBuilder(
                    'ラベルを袋に貼り付け ', color: AppColors.colorBlueDark,
                    bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('てください。',),
              ]
          ),
        ),
      ),
    );
  }

  _buildBody() {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildQrCodeDeletedWarning(),
            _buildQrCodeListViewer(),
          ],
        ),
        Container(
          alignment: Alignment.center,
          child: _primaryQrCodeChanged? AppImages.imgQrCodeLabelErrorStep2
              : _qrCodeChanged? AppImages.imgQrCodeLabelErrorStep3
              : AppImages.imgQrCodeLabelOk,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _buildInstruction(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: _buildMessage(),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: AppImages.imgTagInstruction,
        ),
      ],
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
            onPressed: () => _onPrevScreen(),
            gradient: AppColors.btnGradientLight,
            txtColor: Colors.black,
            showIcon: true,
            icon: Icon(
              Icons.arrow_back_ios, color: Colors.black, size: 14,
            ),
          ),
          GradientButton(
            text: locale.txtCompleteShipping,
            onPressed: () => _completeShipping(),
            showIcon: true,
          ),
        ],
      ),
    );
  }

  _completeShipping() {
    ConfirmationDialog(
        context,
        locale.txtConfirmShippingPreparationCompletion,
        locale.msgConfirmShippingPreparationCompletion,
        locale.txtDone,
            () {
//          int popCount = 0;
//          Navigator.popUntil(context, (route) {
//            return popCount++ == 2;
//          });
            _onCompletion();
        }
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: Stack (
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 60),
            child: _buildBody(),
          ),
          _buildControlBtn(),
        ],
      ),
    );
  }

  _showQrCodeList() async {
    final List resultList = await Navigator.of(context).push(MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return Step5QrCodeListDialog(items: _qrCodes.toList(),);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      if(resultList.isNotEmpty) {
        setState(() {
          String primaryQrCode = _qrCodes.toList()[0];
          _qrCodes.removeAll(resultList);
          _primaryQrCodeChanged = !_qrCodes.contains(primaryQrCode);
          _qrCodeChanged = !_primaryQrCodeChanged;
        });

        ToastUtil.show(
            context,
            '${resultList.join(',')} を削除しました。',
            icon: Icon(Icons.delete, color: Colors.white, size: 16.0,),
            error: true
        );
      }

      // Add new qr code
      // or, All qr code is deleted so return to add qr screen
      if(resultList.isEmpty || _qrCodes.length == 0) {
        _onPrevScreen();
        return;
      }
    }
  }
}