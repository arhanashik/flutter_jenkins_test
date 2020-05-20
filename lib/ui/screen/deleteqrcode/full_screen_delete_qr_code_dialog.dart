import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/response/order_history_details_response.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/util/lib/remote/http_util.dart';

class QrCodeDeleteDialog extends StatefulWidget {

  QrCodeDeleteDialog(
      this.orderHistoryDetails,
      this.qrCodeToDelete,
      this.isPrimary,
      );
  final OrderHistoryDetails orderHistoryDetails;
  final String qrCodeToDelete;
  final bool isPrimary;

  @override
  _QrCodeDeleteDialogState createState() => _QrCodeDeleteDialogState();
}

class _QrCodeDeleteDialogState extends BaseState<QrCodeDeleteDialog> {

  _buildInstruction() {
    final qrCodes = widget.orderHistoryDetails.qrCodes;
    String primaryQrCode = qrCodes[widget.isPrimary? 1:0];
    String primaryQrCodeLast4Digit = primaryQrCode.substring(primaryQrCode.length-4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.isPrimary? Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AppImages.loadSizedImage(AppImages.icDigit2Url, width: 36.0, height: 36.0),
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
                      color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Text('に修正してください。', style: TextStyle(
                color: Colors.black, fontSize: 14,
              ),),
            ],
          ),
        ) : Container(),
        Padding(padding: EdgeInsets.symmetric(vertical: 5),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.loadSizedImage(AppImages.icDigit3Url, width: 36.0, height: 36.0),
            Padding(
              padding: EdgeInsets.only(left: 10,),
              child: Text('の箇所に', style: TextStyle(
                color: Colors.black, fontSize: 14,
              ),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('${locale.txtQuantity}/${qrCodes.length - 1}',
                style: TextStyle(color: Colors.blue,
                    fontSize: 18, fontWeight: FontWeight.bold
                ),),
            ),
            Text('に修正してください。', style: TextStyle(
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
      ],
    );
  }

  _richTextMsgBuilder() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
          children: [
            CommonWidget.textSpanBuilder('配送番号：',),
            CommonWidget.textSpanBuilder(
                widget.orderHistoryDetails.baggageControlNumber.toString(), color: AppColors.colorBlueDark,
                bold: true, fontSize: 14.0
            ),
            CommonWidget.textSpanBuilder(' が記載されたラベルを\n貼り付けた荷物を用意してください。\n用意ができたら、ラベルの\n',),
            CommonWidget.textSpanBuilder(
                ' 「③個口数」', color: AppColors.colorBlueDark, bold: true, fontSize: 14.0
            ),
            CommonWidget.textSpanBuilder('を修正してください。',),
          ]
      ),
    );
  }

  _msgBuilder() {
    return Container(
//      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
      padding: EdgeInsets.symmetric(vertical: 10.0,),
      alignment: Alignment.center,
      child: _richTextMsgBuilder(),
    );
  }

  _buildControlBtn() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 13,),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.colorF1F1F1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GradientButton(
            text: locale.txtCancel,
            onPressed: () => _onWillPop(),
            gradient: AppColors.btnGradientLight,
            txtColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          GradientButton(
            text: locale.txtCompleteShippingPreparation,
            onPressed: () => _deleteConfirmation(),
            showIcon: true,
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
        ],
      ),
    );
  }

  _bodyBuilder() {
    final allQrCodes = List();
    allQrCodes.addAll(widget.orderHistoryDetails.qrCodes.where(
            (element) => element != widget.qrCodeToDelete
    ));

    return Column (
      children: <Widget>[
        Container(
          color: AppColors.colorF1F1F1,
          child: _msgBuilder(),
        ),
        Flexible(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 13),
                alignment: Alignment.center,
                child: AppImages.imgQrCodeLabelOk,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: _buildInstruction(),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                child: CommonWidget.sectionTitleBuilder('修正が必要な配送ラベルの荷物番号'),
              ),
              ListView.builder(
                  itemCount: allQrCodes.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final item = allQrCodes[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      child: Text(item, style: TextStyle(fontSize: 14.0),),
                    );
                  }
              ),
            ],
          ),
        ),
        _buildControlBtn(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Container(
              padding: EdgeInsets.only(left: 9, top: 12, bottom: 12,),
              child: InkWell(
                child: AppImages.loadSizedImage(AppImages.icBackToHistoryUrl,),
                onTap: _onWillPop,
              )
          ),
          title: const Text(''),
        ),
        body: _bodyBuilder(),
      ),
    );
  }

  _deleteConfirmation() {
    ConfirmationDialog(
      context,
      locale.txtConfirmChange,
      locale.msgConfirmChange,
      locale.txtDone,
          () => _deleteQrCode(),
    ).show();
  }

  _deleteQrCode() async {
    CommonWidget.showLoader(context);
    String serial = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = serial;
    params[Params.ORDER_ID] = widget.orderHistoryDetails.orderId;
    params[Params.QR_CODE] = widget.qrCodeToDelete;

    String url = HttpUtil.DELETE_QR_CODE_FROM_HISTORY;
    final response = await HttpUtil.post(url, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      _showSnackBar(locale.errorServerIsNotAvailable);
      return;
    }
    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    final msg = responseMap[Params.MSG];
    if(code != HttpCode.OK) {
      _showSnackBar(msg);
      return;
    }

    SnackbarUtil.show(
        context, 'QRコード\n${widget.qrCodeToDelete}\nを削除しました。',
        durationInSec: 3,
        icon: AppIcons.loadIcon(AppIcons.icDelete, color: Colors.white, size: 16.0),
        background: AppColors.colorAccent
    );
    Navigator.of(context).pop(true);
  }

  Future<bool> _onWillPop() async {
    return (await ConfirmationDialog(
    context,
    '作業を中断して\n対応履歴画面に戻りますか？',
    '中断すると現在行っている\n作業内容は反映されません。\n対応履歴画面に戻ってよろしいですか？',
        locale.txtOk,
    () => Navigator.of(context).pop(),
    msgTxtColor: Colors.red,
    ).show()) ?? false;
  }

  _showSnackBar(String msg) {
    final icon = AppIcons.loadIcon(
        AppIcons.icError, color: Colors.white, size: 16.0
    );
    SnackbarUtil.show(
        context, msg, durationInSec: 3, icon: icon,
        background: AppColors.colorAccent
    );
  }
}