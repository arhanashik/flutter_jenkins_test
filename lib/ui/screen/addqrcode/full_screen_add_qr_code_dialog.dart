import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/response/order_history_details_response.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_1.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_2.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_3.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';

/// Created by mdhasnain
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Full screen dialog to add qr code
/// 2.
/// 3.
class FullScreenAddQrCodeDialog extends StatefulWidget {
  FullScreenAddQrCodeDialog({
    this.orderHistoryDetails,
  });

  final OrderHistoryDetails orderHistoryDetails;

  @override
  _FullScreenAddQrCodeDialogState createState() => new _FullScreenAddQrCodeDialogState();
}

///Total 3 steps to add a new qr code
///1. Scan the qr code
///2. Show the newly added qr code
///3. Show all the qr codes and confirmation
enum Step {
  STEP_1, STEP_2, STEP_3,
}

class _FullScreenAddQrCodeDialogState extends BaseState<FullScreenAddQrCodeDialog> {
  final _newQrCodes = LinkedHashSet<String>();

  Step _currentStep = Step.STEP_1;

  /// build the step view at the top of the screen
  _singleStepBuilder(Step step, String indicatorText) {
    int thisStepIndex = Step.values.indexOf(step);
    int currentStepIndex = Step.values.indexOf(_currentStep);
    bool thisStepActive = thisStepIndex <= currentStepIndex;

    Color textColor = thisStepActive? Colors.white : Colors.black54;
    Color circleColor = thisStepActive? AppColors.colorBlue : Colors.white;
    Color lineColor = thisStepActive? AppColors.colorBlueDark : Colors.white;

    if(step == Step.STEP_1) {
      return CommonWidget.circularText(
          indicatorText, textColor: textColor, circleColor: circleColor
      );
    } else {
      return Row(
        children: <Widget>[
          CommonWidget.line(color: lineColor, width: 40),
          CommonWidget.circularText(
              indicatorText, textColor: textColor, circleColor: circleColor
          ),
        ],
      );
    }
  }

  /// build the step's label(text)
  _singleStepLabelBuilder(Step step, String label) {
    int thisStepIndex = Step.values.indexOf(step);
    int currentStepIndex = Step.values.indexOf(_currentStep);
    bool thisStepActive = thisStepIndex == currentStepIndex;

    Color labelColor = thisStepActive
        ? AppColors.colorBlueDark : AppColors.colorCCCCCC;
    double paddingLeft = step == Step.STEP_1? 0 : 0;
    double paddingTop = Converter.toDp(context, 10);
    double paddingRight = step == Step.STEP_3? 10 : step == Step.STEP_2? 10 : 0;

    return Padding(
      padding: EdgeInsets.only(
          left: paddingLeft, top: paddingTop, right: paddingRight
      ),
      child: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Gather the step view and step label and build the steps view
  Column _stepsBuilder() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _singleStepBuilder(Step.STEP_1, '1'),
            _singleStepBuilder(Step.STEP_2, '2'),
            _singleStepBuilder(Step.STEP_3, '3'),
          ],
        ),
        Container(
          width: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _singleStepLabelBuilder(Step.STEP_1, 'QRコード\n読み取り'),
              _singleStepLabelBuilder(Step.STEP_2, 'ラベル\n記入'),
              _singleStepLabelBuilder(Step.STEP_3, 'ラベル\n修正'),
            ],
          ),
        ),
      ],
    );
  }

  /// provide the step view with state change
  _getStepView(Step step) {
    switch(Step.values.indexOf(step)) {
      case 0:
        return AddQrCodeStep1(
            widget.orderHistoryDetails, _newQrCodes, (newQrCodes) {
              setState(() {
                _newQrCodes.clear();
                _newQrCodes.addAll(newQrCodes);
                _currentStep = Step.STEP_2;
          });
        });

      case 1:
        return AddQrCodeStep2(widget.orderHistoryDetails, _newQrCodes, () {
          setState(() => _currentStep = Step.STEP_1);
        }, () {
          setState(() => _currentStep = Step.STEP_3);
        });

      case 2:
        return AddQrCodeStep3(widget.orderHistoryDetails, _newQrCodes, () {
          setState(() => _currentStep = Step.STEP_2);
        }, () => _updateQrCodes());

      default:
        return Container();
    }
  }

  /// Step's rich text message builder
  _richTextMsgBuilder() {
    RichText richTextMsg;
    switch(_currentStep) {
      case Step.STEP_1:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder('配送番号：',),
                CommonWidget.textSpanBuilder(
                    widget.orderHistoryDetails.baggageControlNumber.toString(), color: AppColors.colorBlueDark,
                    bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder(' にQRコードを追加します。\n',),
                CommonWidget.textSpanBuilder(
                    ' 荷札QRコード', color: AppColors.colorBlueDark, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('をカメラで読み取って下さい。',),
              ]
          ),
        );
        break;
      case Step.STEP_2:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder('追加したラベルに\n',),
                CommonWidget.textSpanBuilder(
                    '「①発送予定時間」、「②配送番号」、\n「③個口数」', color: AppColors.colorBlueDark,
                    bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('を記入してください。',),
              ]
          ),
        );
        break;
      case Step.STEP_3:
        richTextMsg = RichText(
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
        break;
    }

    return richTextMsg;
  }

  /// Every step's message view
  Container _msgBuilder() {
    return Container(
//      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 13.0,),
      padding: EdgeInsets.symmetric(vertical: 10.0,),
      alignment: Alignment.center,
      child: _richTextMsgBuilder(),
    );
  }

  /// Build the body here
  _bodyBuilder() {
    return Container(
      color: AppColors.colorF1F1F1,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8,),
            child: _stepsBuilder(),
          ),
          _msgBuilder(),
          Padding(padding: EdgeInsets.only(top: 8),),
          Flexible(child: _getStepView(_currentStep),)
        ],
      ),
    );
  }

  /// Main function to build and return the screen view
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
        backgroundColor: AppColors.background,
        body: _bodyBuilder(),
      ),
    );
  }

  /// This function works when the back button(widget and device's back button) is pressed
  Future<bool> _onWillPop() async {
    switch(_currentStep) {
      case Step.STEP_2:
        setState(() => _currentStep = Step.STEP_1);
        return false;
      case Step.STEP_3:
        setState(() => _currentStep = Step.STEP_2);
        return false;
      case Step.STEP_1:
      default:
        return (await ConfirmationDialog(
          context,
          '作業を中断して\n対応履歴画面に戻りますか？',
          '中断すると現在行っている\n作業内容は反映されません。\n対応履歴画面に戻ってよろしいですか？',
          locale.txtOk,
          () => Navigator.of(context).pop(),
          msgTxtColor: Colors.red,
        ).show()) ?? false;
    }
  }

  ///Update the newly added qr codes on the server
  _updateQrCodes() async {
    CommonWidget.showLoader(context);
    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = widget.orderHistoryDetails.orderId;
    int qrSerial = widget.orderHistoryDetails.qrCodes.length;
    final qrCodes = List<String>();
    _newQrCodes.forEach((qrCode) {
      String qrStr = "$qrSerial:$qrCode";
      qrCodes.add(qrStr);
      qrSerial++;
    });
    params[Params.QR_CODE_LIST] = qrCodes;

    String url = HttpUtil.ADD_QR_CODE_ON_HISTORY;
    final response = await HttpUtil.post(url, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      _showSnackBar(locale.errorServerIsNotAvailable);
      return;
    }
    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      _showSnackBar('QRコードを追加する事ができませんでした。');
      return;
    }

    String qrCodesStr = _newQrCodes.toList().join('\n');
    _showSnackBar('QRコード\n$qrCodesStr\nを追加しました。', error: false);
    Navigator.of(context).pop(_newQrCodes.toList());
  }

  _showSnackBar(
      String msg, {
        error = true,
      }) {
    final icon = AppIcons.loadIcon (
        error? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    SnackbarUtil.show(
      context, msg, durationInSec: 3, icon: icon,
        background: error? AppColors.colorAccent : AppColors.colorBlue
    );
  }
}