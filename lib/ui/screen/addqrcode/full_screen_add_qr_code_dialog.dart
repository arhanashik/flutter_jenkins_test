import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_1.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_2.dart';
import 'package:o2o/ui/screen/addqrcode/add_qr_code_step_3.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
class FullScreenAddQrCodeDialog extends StatefulWidget {
  FullScreenAddQrCodeDialog({this.orderItem, this.qrCodes});

  final OrderItem orderItem;
  final List<String> qrCodes;

  @override
  _FullScreenAddQrCodeDialogState createState() => new _FullScreenAddQrCodeDialogState(
      orderItem, qrCodes,
  );
}

enum Step {
  STEP_1, STEP_2, STEP_3,
}

class _FullScreenAddQrCodeDialogState extends BaseState<FullScreenAddQrCodeDialog> {

  _FullScreenAddQrCodeDialogState(this._orderItem, this._qrCodes);

  final OrderItem _orderItem;
  List<String> _qrCodes = List();
  List<String> _tempQrCodes = List();

  Step _currentStep = Step.STEP_1;
  List _stepScreens = List();

  _initStepScreens() {
    _stepScreens = [
      AddQrCodeStep1(_qrCodes, (qrCodes) {
        setState(() {
          _tempQrCodes.clear();
          _tempQrCodes.addAll(qrCodes);
          _currentStep = Step.STEP_2;
        });
      }),
      AddQrCodeStep2(_orderItem, _tempQrCodes, () {
        setState(() => _currentStep = Step.STEP_1);
      }, () {
        setState(() => _currentStep = Step.STEP_3);
      }),
      AddQrCodeStep3(_orderItem, _tempQrCodes, () {
        setState(() => _currentStep = Step.STEP_2);
      }, () {
        setState(() => _qrCodes = _tempQrCodes);
        Navigator.of(context).pop(_qrCodes);
      }),
    ];
  }

  _singleStepBuilder(Step step, String indicatorText) {
    int thisStepIndex = Step.values.indexOf(step);
    int currentStepIndex = Step.values.indexOf(_currentStep);
    bool thisStepActive = thisStepIndex <= currentStepIndex;

    Color textColor = thisStepActive? Colors.white : Colors.black54;
    Color circleColor = thisStepActive? Colors.lightBlue : Colors.white;
    Color lineColor = thisStepActive? Colors.lightBlue : Colors.white;

    if(step == Step.STEP_1) {
      return CommonWidget.circularText(
          indicatorText, textColor: textColor, circleColor: circleColor
      );
    } else {
      return Row(
        children: <Widget>[
          CommonWidget.line(color: lineColor, width: 48.0),
          CommonWidget.circularText(
              indicatorText, textColor: textColor, circleColor: circleColor
          ),
        ],
      );
    }
  }

  _singleStepLabelBuilder(Step step, String label) {
    int thisStepIndex = Step.values.indexOf(step);
    int currentStepIndex = Step.values.indexOf(_currentStep);
    bool thisStepActive = thisStepIndex <= currentStepIndex;

    Color labelColor = thisStepActive? Colors.lightBlue : Colors.black26;
    double paddingLeft = step == Step.STEP_1? 0 : 14;
    double paddingTop = 8;
    double paddingRight = step == Step.STEP_3? 0 : 14;

    return Padding(
      padding: EdgeInsets.only(
          left: paddingLeft, top: paddingTop, right: paddingRight
      ),
      child: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _singleStepLabelBuilder(Step.STEP_1, locale.txtPackingStep1),
            _singleStepLabelBuilder(Step.STEP_2, locale.txtPackingStep2),
            _singleStepLabelBuilder(Step.STEP_3, locale.txtPackingStep3),
          ],
        ),
      ],
    );
  }

  _getStepView(Step step) {
    int stepIndex = Step.values.indexOf(step);
    return _stepScreens[stepIndex];
  }

  TextSpan _textSpanBuilder(
      String text, {
        Color color = Colors.black,
        FontWeight fontWeight = FontWeight.w500
      }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: fontWeight,
      ),
    );
  }

  RichText _richTextMsgBuilder() {
    RichText richTextMsg;
    switch(_currentStep) {
      case Step.STEP_1:
        String msg = locale.txtBaggageManagementNumber + ':4444に追加します。'
            '\n荷札QRコードをカメラで読み取って下さい。';
        richTextMsg = RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder(msg,),
              ]
          ),
        );
        break;
      case Step.STEP_2:
        richTextMsg = RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder('追加したラベルに',),
                _textSpanBuilder('「発送予定時間」、「荷物管理番号」、「個口数」', color: Colors.lightBlue, fontWeight: FontWeight.bold),
                _textSpanBuilder('を記入してください。',),
              ]
          ),
        );
        break;
      case Step.STEP_3:
        richTextMsg = RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder(locale.txtBaggageManagementNumber + ':4444', color: Colors.lightBlue, fontWeight: FontWeight.bold),
                _textSpanBuilder('が記載されたラベルを貼り付けた荷物を用意してください。\n用意ができたら、ラベルの',),
                _textSpanBuilder('「個口数」', color: Colors.lightBlue, fontWeight: FontWeight.bold),
                _textSpanBuilder('を修正してください。',),
              ]
          ),
        );
        break;
    }

    return richTextMsg;
  }

  Container _msgBuilder() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: _richTextMsgBuilder(),
    );
  }

  _bodyBuilder() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: _stepsBuilder(),
          ),
          _msgBuilder(),
          Flexible(child: _getStepView(_currentStep),)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initStepScreens();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close, color: Colors.white,),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      backgroundColor: Color.fromARGB(255, 230, 242, 255),
      body: _bodyBuilder(),
    );
  }
}