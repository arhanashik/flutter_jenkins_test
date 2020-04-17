import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/choice/choice.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/packing_list.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_1.dart';
import 'package:o2o/ui/screen/packing/step_2.dart';
import 'package:o2o/ui/screen/packing/step_3.dart';
import 'package:o2o/ui/screen/packing/step_4.dart';
import 'package:o2o/ui/screen/packing/step_5.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_stock_out_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_order_list_dialog.dart';
import 'package:o2o/ui/widget/popup/shape_widget.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';

/// Created by mdhasnain on 15 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Show the 5 packing steps. They are
///   Step 1: Show the packing product list, delivery time, product count
///      and price
///   Step 2: Get the receipt number input
///   Step 3: Show the instruction of packing
///   Step 4: Show the QR code scanner to get the qr code of the products
///   Step 5: Show the info of the order, qr code list and complete the packing
/// 2. Scan product with barcode scanner
/// 3. Add new product after checking the barcode on server
/// 4. Check the missing product status
///
class PackingScreen extends StatefulWidget {
  PackingScreen({
    Key key,
    @required this.orderItem,
    @required this.isUnderWork
  }) : super(key: key);
  final OrderItem orderItem;
  final bool isUnderWork;

  @override
  _PackingScreenState createState() => _PackingScreenState(
      orderItem, isUnderWork
  );
}

enum Step {
  STEP_1, STEP_2, STEP_3, STEP_4, STEP_5,
}

class _PackingScreenState extends BaseState<PackingScreen> {
  _PackingScreenState(this._orderItem, this._isUnderWork);
  final OrderItem _orderItem;
  final bool _isUnderWork;
  String _receiptNumber;
  bool _orderCompleted = false;

  PackingList _packingList;

  final _scannedQrCodes = LinkedHashSet<String>();

  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[1]) _checkStockOutStatus();
    else if(_selectedChoice == _choices[2]) {
      if(_packingList == null) return;
      Navigator.of(context).push(new MaterialPageRoute<List>(
          builder: (BuildContext context) {
            return FullScreenOrderListDialog(
              items: _packingList.products,
            );
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
      Step1Screen(_orderItem, () => setState(() =>_currentStep = Step.STEP_2),
            (packingList) => setState(() => _packingList = packingList),
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
        _orderItem, _scannedQrCodes, _isUnderWork,
        () => setState(() => _currentStep = Step.STEP_3),
        (qrCodes) {
          setState(() {
            _scannedQrCodes.addAll(qrCodes);
            _currentStep = Step.STEP_5;
          });
          print('ll ${qrCodes.length}, gg ${_scannedQrCodes.length}');
        }
      ),
      Step5Screen(
        _orderItem,
        _scannedQrCodes,
        () => setState(() {
          _orderCompleted = false;
          _currentStep = Step.STEP_4;
        }),
        () => _updatePackingInfo(),
      )
    ];
  }

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

  _singleStepLabelBuilder(Step step, String label) {
    int thisStepIndex = Step.values.indexOf(step);
    int currentStepIndex = Step.values.indexOf(_currentStep);
    bool thisStepActive = thisStepIndex == currentStepIndex;

    Color labelColor = thisStepActive
        ? AppColors.colorBlueDark : AppColors.colorCCCCCC;
    double paddingLeft = step == Step.STEP_1? 0 : 0;
    double paddingTop = Common.toDp(context, 10);
    double paddingRight = step == Step.STEP_5? 5 : 0;

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

  _stepsBuilder() {
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  _richTextMsgBuilder() {
    RichText richTextMsg;
    switch(_currentStep) {
      case Step.STEP_1:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder(
                    'レジに商品を通して、', color: AppColors.colorBlueDark,
                    bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('\n商品価格を',),
                CommonWidget.textSpanBuilder(
                    ' EC価格 ', color: AppColors.colorBlueDark, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('に修正して\n登録してください。',),
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
                CommonWidget.textSpanBuilder('出てきだレシートを記載されている\n４桁の',),
                CommonWidget.textSpanBuilder(
                    ' レシート番号 ', color: AppColors.colorBlueDark, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('を\n入力してください。',),
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
                CommonWidget.textSpanBuilder('商品を袋に詰め、', ),
                CommonWidget.textSpanBuilder('荷札QRコードの印刷された\nラベル',
                    color: AppColors.colorBlueDark, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('を必要な枚数準備してください。',),
              ]
          ),
        );
        break;
      case Step.STEP_4:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder(
                    '荷札QRコード ', color: AppColors.colorBlue, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('を\nカメラで読み取って下さい。',),
              ]
          ),
        );
        break;
      case Step.STEP_5:
        richTextMsg = RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder('QRコードを読み取ったラベルに\n',),
                CommonWidget.textSpanBuilder('「①発送予定時間」、「②出荷番号記」、\n「③個数/個口数」',
                    color: AppColors.colorBlue, bold: true, fontSize: 14.0
                ),
                CommonWidget.textSpanBuilder('を記入してください。',),
              ]
          ),
        );
        break;
    }

    return richTextMsg;
  }

  _msgBuilder() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0,),
      alignment: Alignment.center,
      child: _richTextMsgBuilder(),
    );
  }

  _getStepView(Step step) {
    int stepIndex = Step.values.indexOf(step);
    return _stepScreens[stepIndex];
  }

 _bodyBuilder() {
    return Container(
      child: Column(
        children: <Widget>[
          Container (
            color: AppColors.colorF1F1F1,
            padding: EdgeInsets.only(
              top: Common.toDp(context, 18.0),
              bottom: Common.toDp(context, 14.0),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: Common.toDp(context, 16.0),
                      right: Common.toDp(context, 16.0),
                      bottom: Common.toDp(context, 16.0),
                  ),
                  child: _stepsBuilder(),
                ),
                _msgBuilder(),
              ],
            ),
          ),
          Flexible(child: _getStepView(_currentStep),)
        ],
      ),
    );
  }

  bool _menuShown = false;
  _buildMenu() {
    return Container(
      color: Colors.white,
      width: 180.0,
      child: Column(
        children: <Widget>[
          Visibility(
            child: InkWell(
              child: Padding(
                child: Text(
                  locale.txtReportStorage,
                  style: TextStyle(
                      color: AppColors.colorBlueDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              onTap: (){
                setState(() => _menuShown = !_menuShown);
                _checkStockOutStatus();
              },
            ),
            visible: _currentStep == Step.STEP_1,
          ),
          Container(
            height: _currentStep == Step.STEP_1? 1.5 : 0,
            color: AppColors.colorF1F1F1,
          ),
          InkWell(
            child: Padding(
              child: Text(
                locale.txtSeeOrderList,
                style: TextStyle(
                    color: AppColors.colorBlueDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0,),
            ),
            onTap: () {
              setState(() => _menuShown = !_menuShown);
              _showOrderProductList();
            },
          ),
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
    _initStepScreens();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: TopBar (
          title: locale.txtShippingPreparation,
          navigationIcon: AppIcons.loadIcon(
              AppIcons.icBackToList, size: 48.0, color: AppColors.colorBlue
          ),
          iconColor: AppColors.colorBlue,
          background: Colors.white,
//          menu: PopupMenuButton(
//              child: AppIcons.loadIcon(
//                  AppIcons.icSettings, size: 48.0, color: AppColors.colorBlue
//              ),
//              onSelected: _select,
//              itemBuilder: (BuildContext context) {
//                final choices = _currentStep == Step.STEP_1? _choices.skip(1)
//                      : [_choices[2]];
//                return choices.map((Choice choice) {
//                  return PopupMenuItem<Choice>(
//                    value: choice,
//                    child: Text(choice.title),
//                  );
//                }).toList();
//              }),
          menu: InkWell(
            child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: AppColors.colorBlue),
            onTap: () => setState(() => _menuShown = !_menuShown),
          ),
          onTapNavigation: () => _onWillPop(),
          error: _isUnderWork? '${_orderItem.lockedName}が作業中' : '',
        ),
        backgroundColor: AppColors.background,
        body: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _bodyBuilder(),
            Visibility(
              child: Positioned(
                child: ShapedWidget(
                  child: _buildMenu(),
                  background: AppColors.colorBlue,
                ),
                right: 13.0,
                top: 10.0,
              ),
              visible: _menuShown,
            ),
          ],
        ),
      ),
    );
  }

  _checkStockOutStatus() async {
    final products = List<ProductEntity>();
    _packingList.products.forEach((element) {
      if(element is ProductEntity) products.add(element);
    });
    final resultList = await Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenStock0utDialog(
            orderItem: _orderItem, products: products,
          );
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      String msg = '欠品のため注文番号：${_orderItem.orderId}...はキャンセルになりました。';
      SnackbarUtil.show(
        context, msg, background: AppColors.colorAccent,
        icon: Icon(Icons.cancel, size: 24, color: Colors.white,),
      );
      Navigator.of(context).pop();
    }
  }

  _showOrderProductList() {
    if(_packingList == null) return;
    Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenOrderListDialog(
            items: _packingList.products,
          );
        },
        fullscreenDialog: true
    ));
  }

  _updateReceiptNumber(String receiptNo) async {
    _receiptNumber = receiptNo;
//    CommonWidget.showLoader(context, cancelable: true);
//    String imei = await PrefUtil.read(PrefUtil.IMEI);
//    final params = HashMap();
//    params['imei'] = imei;
//    params['orderId'] = _orderItem.orderId;
//    params['receiptNo'] = _receiptNumber;
//
//    final response = await HttpUtil.post(HttpUtil.UPDATE_RECEIPT_NUMBER, params);
//    Navigator.of(context).pop();
//    final data = _validateResponse(response, 'Failed to update receipt number');
//    if(data == null) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }
    setState(() => _currentStep = Step.STEP_3);
  }

  /// Register packing information(qr codes, imei, orderId..etc) to server
  /// After that call _completeOrder() to update packing status and complete
  /// the order
  _updatePackingInfo() async {
    if(!isOnline) {
      ToastUtil.show(
          context, 'Connect to internet first',
          icon: Icon(Icons.error, color: Colors.white,), error: true
      );
      return;
    }

    if(_orderCompleted) _completeOrder();

    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final qrCodes = _scannedQrCodes.toList();
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    params['receiptNo'] = _receiptNumber;
    params['primaryQrCode'] = "${qrCodes[0]}";
    params['otherQrCode'] = qrCodes.length > 1? qrCodes.sublist(1) : List();
    //params['status'] = PackingStatus.DONE;

    final response = await HttpUtil.post(HttpUtil.UPDATE_PACKING_QR_CODE, params);
    Navigator.of(context).pop();
    final data = _validateResponse(response, 'Qrコード一覧は登録する事ができません');
    if(data == null) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    _orderCompleted = true;
    _completeOrder();
  }

  /// Update the packing status as DONE.
  /// If successfully updated, close packing screen and return to order list
  _completeOrder() async {
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    params['status'] = PackingStatus.DONE;

    final response = await HttpUtil.post(HttpUtil.UPDATE_PACKING_STATUS, params);
    Navigator.of(context).pop();
    final data = _validateResponse(response, 'パッキングstatusは更新する事ができません');
    if(data == null) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    Navigator.of(context).pop({'order_id': _orderItem.orderId});
  }

  _validateResponse(response, String errorMsg) {
    if (response.statusCode != HttpCode.OK) {
      ToastUtil.show(
          context, locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,), error: true
      );
      return null;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    if(code != HttpCode.OK) {
      ToastUtil.show(context, errorMsg);
      return null;
    }

    return responseMap['data'];
  }
}
