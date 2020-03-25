import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_5_qr_code_list_dialog.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
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

//  _buildLabelExample() {
//    return Column (
//      children: <Widget>[
//        Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Container(
//              decoration: BoxDecoration(
//                border: Border.all(color: Colors.grey)
//              ),
//              padding: EdgeInsets.all(16),
//              child: SvgPicture.asset(
//                  'assets/images/qr.svg',
//                width: 100.0,
//                height: 100.0,
//                color: Colors.black54,
//              ),
//            ),
//            Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  width: MediaQuery.of(context).size.width - 154,
//                  decoration: BoxDecoration(
//                      border: Border.all(color: Colors.grey)
//                  ),
//                  padding: EdgeInsets.all(5),
//                  child: Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Text(locale.txtShippingPlanTime, style: TextStyle(
//                        color: Colors.black54, fontSize: 12,
//                      ),),
//                      Container(
//                        decoration: BoxDecoration(
//                          border: Border.all(color: Colors.blue, width: 3),
//                          borderRadius: BorderRadius.all(Radius.circular(5)),
//                        ),
//                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                        margin: EdgeInsets.only(left: 10),
//                        child: Text('1', style: TextStyle(
//                          color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
//                        ),),
//                      ),
//                    ],
//                  ),
//                ),
//                Container(
//                  width: MediaQuery.of(context).size.width - 154,
//                  child: Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      Container(
//                        width: MediaQuery.of(context).size.width - 154 - 80,
//                        height: 85,
//                        decoration: BoxDecoration(
//                            border: Border.all(color: Colors.grey)
//                        ),
//                        padding: EdgeInsets.all(5),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Text(locale.txtDeliveryNumber, style: TextStyle(
//                              color: Colors.black54, fontSize: 12,
//                            ),),
//                            Container(
//                              decoration: BoxDecoration(
//                                border: Border.all(color: Colors.blue, width: 3),
//                                borderRadius: BorderRadius.all(Radius.circular(5)),
//                              ),
//                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                              margin: EdgeInsets.only(top: 16),
//                              child: Text('2', style: TextStyle(
//                                  color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
//                              ),),
//                            ),
//                          ],
//                        ),
//                      ),
//                      Container(
//                        width: 80,
//                        height: 85,
//                        decoration: BoxDecoration(
//                            border: Border.all(color: Colors.grey)
//                        ),
//                        padding: EdgeInsets.all(5),
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//                            Text('${locale.txtQuantity}/${locale.txtNumberOfPieces}',
//                              style: TextStyle(
//                                color: Colors.black54, fontSize: 12,
//                              ),
//                              textAlign: TextAlign.center,
//                            ),
//                            Container(
//                              decoration: BoxDecoration(
//                                border: Border.all(color: Colors.blue, width: 3),
//                                borderRadius: BorderRadius.all(Radius.circular(5)),
//                              ),
//                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                              margin: EdgeInsets.only(top: 10),
//                              child: Text('3', style: TextStyle(
//                                  color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
//                              ),),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ],
//                  ),
//                )
//              ],
//            )
//          ],
//        ),
//        Container(
//          decoration: BoxDecoration(
//              border: Border.all(color: Colors.grey)
//          ),
//          padding: EdgeInsets.all(5),
//          child: Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text(locale.txtBaggageNumber, style: TextStyle(
//                color: Colors.black54, fontSize: 12,
//              ),),
//              Container(
//                margin: EdgeInsets.only(left: 24, top: 10, bottom: 15),
//                child: Text('1111-2222-3333',
//                  style: TextStyle(
//                      color: Colors.black, fontSize: 18,
//                  ),
//                ),
//              ),
//            ],
//          ),
//        ),
//        Container(
//          decoration: BoxDecoration(
//              border: Border.all(color: Colors.grey)
//          ),
//          padding: EdgeInsets.all(5),
//          child: Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text(locale.txtComment, style: TextStyle(
//                color: Colors.black54, fontSize: 12,
//              ),),
//              Container(
//                margin: EdgeInsets.only(left: 24, top: 10, bottom: 15),
//                child: Text('',
//                  style: TextStyle(
//                    color: Colors.black, fontSize: 18,
//                  ),
//                ),
//              ),
//            ],
//          ),
//        ),
//      ],
//    );
//  }

  _buildInstruction() {
    String primaryQrCode = _qrCodes.isEmpty? '12121212' : _qrCodes.toList()[0];
    String primaryQrCodeLast4Digit = primaryQrCode.substring(primaryQrCode.length-4);

    final deliveryDate = Common.convertToDateTime(_orderItem.deliveryTime);

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
              child: Text('${locale.txtQuantity}/${_orderItem.productCount}',
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
            Text(' には1/2と記入してください。', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 2.5),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('＊荷物が2つの場合、', style: TextStyle(
              color: Colors.black, fontSize: 12,
            ),),
            AppImages.icDigit3,
            Text(' には2/2と記入してください。', style: TextStyle(
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

  TextSpan _textSpanBuilder(
      String text, {
        Color color = Colors.black,
        bool bold = false
      }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: bold? FontWeight.bold: FontWeight.normal,
      ),
    );
  }

//  Container _sectionTitleBuilder(title) {
//    return Container(
//      decoration: BoxDecoration(
//        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
//      ),
//      child: Padding(
//        padding: EdgeInsets.only(left: 10),
//        child: Text(
//          title,
//          style: TextStyle(
//              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//        ),
//      ),
//    );
//  }

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
        margin: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                _textSpanBuilder('ラベルは記入が終わりましたら、\n',),
                _textSpanBuilder('ラベルを袋に貼り付け', color: Colors.lightBlue, bold: true),
                _textSpanBuilder('てください。',),
              ]
          ),
        ),
      ),
    );
  }

  _buildBody() {
    return ListView(
      children: <Widget>[
//        Padding(
//          padding: EdgeInsets.all(10),
//          child: _buildLabelExample(),
//        ),
        Visibility(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              locale.warningUpdateLabelInfo,
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700
              ),
              textAlign: TextAlign.center,
            ),
          ),
          visible: _primaryQrCodeChanged || _qrCodeChanged,
        ),
        InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
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
//        Padding(
//          padding: EdgeInsets.all(10),
//          child: Text(
//            '${locale.txtOrderNumber}: 111111333',
//            style: TextStyle(
//              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,
//            ),
//          ),
//        ),
//        Padding(
//          padding: EdgeInsets.all(10),
//          child: _sectionTitleBuilder(locale.txtQRScannedLabeledCount),
//        ),
//        Padding(
//          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//          child: Text(
//            qrCodes.join('\n'),
//            style: TextStyle(
//              color: Colors.black, fontSize: 16, height: 1.5
//            ),
//          ),
//        ),
//        Container(
//          margin: EdgeInsets.symmetric(vertical: 10),
//          height: 1,
//          color: Colors.black12,
//        )
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
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
            padding: EdgeInsets.only(bottom: 70),
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
      if(resultList.length == _qrCodes.length) {
        _onPrevScreen();
        return;
      }

      setState(() {
        String primaryQrCode = _qrCodes.toList()[0];
        _primaryQrCodeChanged = resultList.contains(primaryQrCode);
        _qrCodeChanged = !_primaryQrCodeChanged;
        _qrCodes.removeAll(resultList);
      });

      ToastUtil.show(
        context,
        '${resultList.join(',')} を削除しました。',
        icon: Icon(Icons.delete, color: Colors.white,),
        error: true
      );
    }
  }
}