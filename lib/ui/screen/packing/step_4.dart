import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/screen/packing/step_4_qr_code_list_dialog.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Step4Screen extends StatefulWidget {

  Step4Screen(
      this.orderItem,
      this.qrCodes,
      this.isUnderWork,
      this.onPrevScreen,
      this.onNextScreen
  );
  final OrderItem orderItem;
  final LinkedHashSet<String> qrCodes;
  final bool isUnderWork;
  final Function onPrevScreen;
  final Function onNextScreen;

  @override
  _Step4ScreenState createState() => _Step4ScreenState(
      orderItem, qrCodes, isUnderWork, onPrevScreen, onNextScreen
  );
}

class _Step4ScreenState extends BaseState<Step4Screen> {

  _Step4ScreenState(
      this._orderItem,
      this._scannedQrCodes,
      this._isUnderWork,
      this._onPrevScreen,
      this._onNextScreen
  );
  final OrderItem _orderItem;
  final LinkedHashSet<String> _scannedQrCodes;
  final bool _isUnderWork;
  final Function _onPrevScreen;
  final Function _onNextScreen;
  String _myIMEI;

  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QRCodeScanner');
  var _qrText = "";
  QRViewController _controller;
  bool _flashOn = false;

  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16,),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  _sectionQRCodeScanner() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          height: _isUnderWork? 246 : 275,
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Icon(
              _flashOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.lightBlue,
            ),
            padding: EdgeInsets.all(2),
          ),
          onTap: _toggleFlush,
        ),
      ],
    );
  }

  _returnToPreviousStep() {
    ConfirmationDialog(
      context,
      locale.txtReturnToPreviousStep,
      locale.msgReturnToPreviousStep,
      locale.txtOk,
      _onPrevScreen,
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
            onPressed: () => _returnToPreviousStep(),
            gradient: AppColors.btnGradientLight,
            txtColor: Colors.black,
            showIcon: true,
            icon: Icon(
              Icons.arrow_back_ios, color: Colors.black, size: 14,
            ),
          ),
          GradientButton(
            text: locale.txtGoToAddLabel,
            onPressed: () => _onNextScreen(_scannedQrCodes),
            showIcon: true,
            enabled: _scannedQrCodes.isNotEmpty,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {_scannedQrCodes.add('11111');});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _sectionTitleBuilder('${locale.txtQRScannedLabeledCount}: ${_scannedQrCodes.length}'),
              Spacer(),
              Container(
                height: 48.0,
                padding: EdgeInsets.all(5),
                child: GradientButton(
                  text: locale.txtSeeList,
                  onPressed: () => _showScannedQrCodeList(),
                  padding: EdgeInsets.all(10.0),
                ),
              ),
            ],
          ),
          _sectionQRCodeScanner(),
          Spacer(),
          _buildControlBtn(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _qrText = scanData;
        _pauseCamera();
        _checkQrProduct(_qrText);
      });
    });
  }

  void _toggleFlush() {
    _controller?.toggleFlash();
    setState(() => _flashOn = !_flashOn);
  }

  void _pauseCamera() {
    _controller?.pauseCamera();
  }

  void _resumeCamera() {
    _controller?.resumeCamera();
  }

  _checkQrProduct(qrCode) async {
    if(_scannedQrCodes.contains(qrCode)) {
      ToastUtil.show(
          context, '読み取り済みQRコード',
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      _resumeCamera();
      return;
    }

    if(!isOnline) {
      ToastUtil.show(
          context, locale.errorInternetIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      _resumeCamera();
      return;
    }

    setState(() => loadingState = LoadingState.LOADING);
    CommonWidget.showLoader(context, cancelable: true);
    if(_myIMEI == null) _myIMEI = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = _myIMEI;
    params['orderId'] = _orderItem.orderId;
    params['qrCode'] = qrCode;

    final response = await HttpUtil.get(HttpUtil.CHECK_PACKING_QR_CODE, params: params);
    Navigator.of(context).pop();
    _resumeCamera();

    if (response.statusCode != 200) {
      setState(() => loadingState = LoadingState.ERROR);
      ToastUtil.show(
          context, locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    final msg = responseMap['msg'];
    if(code == PackingQrCodeStatus.NOT_ISSUED) {
      setState(() => loadingState = LoadingState.ERROR);
      ToastUtil.show(
          context, msg,
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      return;
    }

    if(code == PackingQrCodeStatus.REGISTERED) {
      ToastUtil.show(
          context, msg,
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      //return;
    }

    setState(() => _scannedQrCodes.add(_qrText));
    ToastUtil.show(context, locale.txtScanned1QRCode, verticalMargin: 200,);
  }

  _showScannedQrCodeList() async {
    final List resultList = await Navigator.of(context).push(
        MaterialPageRoute<List>(builder: (BuildContext context) {
          return Step4QrCodeListDialog(items: _scannedQrCodes.toList(),);
        },
            fullscreenDialog: true
        ));

    if (resultList != null) {
      setState(() => _scannedQrCodes.removeAll(resultList));

      ToastUtil.show(
        context,
        '${resultList.join(',')} を削除しました。',
        icon: Icon(Icons.delete, color: Colors.white,),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

}