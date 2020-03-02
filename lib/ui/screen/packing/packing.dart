import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/data/choice/choice.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_1.dart';
import 'package:o2o/ui/screen/packing/step_2.dart';
import 'package:o2o/ui/screen/packing/step_3.dart';
import 'package:o2o/ui/screen/packing/step_4.dart';
import 'package:o2o/ui/screen/packing/step_5.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_missing_information_checker_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_order_list_dialog.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/HttpUtil.dart';

class PackingScreen extends StatefulWidget {
  final OrderItem orderItem;

  PackingScreen({Key key, this.orderItem}) : super(key: key);

  @override
  _PackingScreenState createState() => _PackingScreenState(orderItem: orderItem);
}

enum Step {
  STEP_1, STEP_2, STEP_3, STEP_4, STEP_5,
}

class _PackingScreenState extends BaseState<PackingScreen> {
  _PackingScreenState({this.orderItem});

  final OrderItem orderItem;
  String url = "https://swapi.co/api/people";

  List _scannedProducts = List();

  final _scannedQrCodes = HashSet<String>();

  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[1]) _checkMissingInformation();
    else if(_selectedChoice == _choices[2]) {
      Navigator.of(context).push(new MaterialPageRoute<List>(
          builder: (BuildContext context) {
            return FullScreenOrderListDialog(items: _scannedProducts,);
          },
          fullscreenDialog: true
      ));
    }
  }

  void _initChoices() {
    _choices.clear();
    _choices.add(Choice(title: locale.txtSettings, icon: Icons.settings));
    _choices.add(Choice(title: locale.txtReportStorage, icon: Icons.report));
    _choices.add(Choice(title: locale.txtSeeOrderList, icon: Icons.view_list));

    _selectedChoice = _choices[0];
  }

  Step _currentStep = Step.STEP_1;
  List _stepScreens = List();

  _initStepScreens() {
    _stepScreens = [
      Step1Screen(orderItem, _scannedProducts,
        () => setState(() => _currentStep = Step.STEP_2)
      ),
      Step2Screen(
        () => setState(() => _currentStep = Step.STEP_1),
        (pin) => _updateReceiptNumber(pin)
      ),
      Step3Screen(
        () => setState(() => _currentStep = Step.STEP_2),
        () => setState(() => _currentStep = Step.STEP_4)
      ),
      Step4Screen(
        () => setState(() => _currentStep = Step.STEP_3),
        (qrCodes) {
          setState(() {
            _scannedQrCodes.addAll(qrCodes);
            _currentStep = Step.STEP_5;
          });
        }
      ),
      Step5Screen(
        _scannedQrCodes.toList(),
        () => setState(() => _currentStep = Step.STEP_4),
        () => _completePacking(),
      )
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
          CommonWidget.line(color: lineColor),
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
    double paddingLeft = step == Step.STEP_1? 0 : 8;
    double paddingTop = 8;
    double paddingRight = step == Step.STEP_5? 0 : 8;

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
            _singleStepBuilder(Step.STEP_4, '4'),
            _singleStepBuilder(Step.STEP_5, '5'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _singleStepLabelBuilder(Step.STEP_1, locale.txtPackingStep1),
            _singleStepLabelBuilder(Step.STEP_2, locale.txtPackingStep2),
            _singleStepLabelBuilder(Step.STEP_3, locale.txtPackingStep3),
            _singleStepLabelBuilder(Step.STEP_4, locale.txtPackingStep4),
            _singleStepLabelBuilder(Step.STEP_5, locale.txtPackingStep5),
          ],
        ),
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
          fontSize: 16,
          fontWeight: bold? FontWeight.bold: FontWeight.normal,
        ),
    );
  }

  RichText _richTextMsgBuilder() {
    RichText richTextMsg;
    switch(_currentStep) {
      case Step.STEP_1:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: [
              _textSpanBuilder('レジに商品を通して、', color: AppColors.colorBlueDark, bold: true),
              _textSpanBuilder('\n商品価格を',),
              _textSpanBuilder('EC価格', color: AppColors.colorBlueDark, bold: true),
              _textSpanBuilder('に修正して\n登録してください。',),
            ]
          ),
        );
        break;
      case Step.STEP_2:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder('出てきだレシートを記載されている\n４桁の',),
                _textSpanBuilder('レシート番号', color: AppColors.colorBlueDark, bold: true),
                _textSpanBuilder('を\n入力してください。',),
              ]
          ),
        );
        break;
      case Step.STEP_3:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder('商品を袋に詰め、荷札QRコードの\n印刷されたラベルを',),
                _textSpanBuilder('袋の数ぶん', color: AppColors.colorBlueDark, bold: true),
                _textSpanBuilder('\n準備してください。',),
              ]
          ),
        );
        break;
      case Step.STEP_4:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder('荷札QRコード', color: AppColors.colorBlueDark, bold: true),
                _textSpanBuilder('を\nカメラで読み取って下さい。',),
              ]
          ),
        );
        break;
      case Step.STEP_5:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                _textSpanBuilder('ラベルに',),
                _textSpanBuilder('「①発送予定時間」、\n「②出荷番号記」、「③個数/個口数」', color: AppColors.colorBlueDark, bold: true),
                _textSpanBuilder('を\n記入してください。',),
              ]
          ),
        );
        break;
    }

    return richTextMsg;
  }

  Container _msgBuilder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: _richTextMsgBuilder(),
    );
  }

  _getStepView(Step step) {
    int stepIndex = Step.values.indexOf(step);
    return _stepScreens[stepIndex];
  }

  _checkMissingInformation() async {
    final resultList = await Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenMissingInformationCheckerDialog(items: _scannedProducts,);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      ToastUtil.showCustomToast(
        context,
        '商品を削除しました。',
        icon: Icon(Icons.close,),
      );
      Navigator.of(context).pop();
    }
  }

  Container _bodyBuilder() {
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

  Future<bool> _onWillPop() async {
    return (await ConfirmationDialog(
      context,
      locale.txtCancelPacking,
      locale.msgCancelPacking,
      locale.txtReturnToTheList,
        () {
          int popCount = 0;
          Navigator.popUntil(context, (route) {
            return popCount++ == 2;
          });
        },
      msgTxtColor: Colors.red,
    ).show()) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderList();
    _initStepScreens();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(locale.txtShippingPreparation),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
                icon: Icon(_choices[0].icon),
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  final choices = _currentStep == Step.STEP_1? _choices.skip(1)
                      : [_choices[2]];
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                }),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 230, 242, 255),
        body: _bodyBuilder(),
      ),
    );
  }

  _fetchOrderList() {
    _scannedProducts.addAll(ProductEntity.dummyProducts());
    setState(() => loadingState = LoadingState.OK);
  }

  _updateReceiptNumber(String receiptNo) async {
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['orderNo'] = orderItem.orderNo;
    requestBody['receiptNo'] = receiptNo;

    final response = await HttpUtil.postReq(AppConst.UPDATE_RECEIPT_NUMBER, requestBody);
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      SnackbarUtil.show(context, 'Failed to upate receipt number');
      return;
    }

    setState(() => _currentStep = Step.STEP_3);
  }

  _completePacking() async {
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['orderNo'] = orderItem.orderNo;
    requestBody['status'] = PickingStatus.WORKING;

    final response = await HttpUtil.postReq(AppConst.UPDATE_PICKING_STATUS, requestBody);
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      SnackbarUtil.show(context, 'Failed to upate picking status');
      return;
    }

    Navigator.of(context).pop({'order_id': orderItem.orderNo});
  }
}
