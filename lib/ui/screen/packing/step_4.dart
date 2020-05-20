import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_4_qr_code_list_dialog.dart';
import 'package:o2o/ui/screen/packing/step_4_scanner_overlay_shape.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
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
//  QRViewController _controller;
  QRViewController _controller;
  bool _flashOn = false;

  _sectionQRCodeScanner() {
//    return QrScanner(
//        height: _isUnderWork? 300.0 : 330.0,
//        controller: _controller, onQrCode: (qrCode) {
//      _checkQrProduct(qrCode);
//    });
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: Step4ScannerOverlayShape(
              borderColor: AppColors.colorBlue,
              borderRadius: 0,
              borderLength: 13,
              borderWidth: 5,
              cutOutSize: 160,
            ),
          ),
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.all(16),
            child: _flashOn ? AppImages.icFlushOn : AppImages.icFlushOff,
          ),
          onTap: _toggleFlush,
        ),
      ],
    );
  }

  _returnToPreviousStep() {
    ToastUtil.clear();
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
            onPressed: () {
              ToastUtil.clear();
              _onNextScreen(_scannedQrCodes);
            },
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
//    setState(() {_scannedQrCodes.addAll(['1111-1111-1111-1111', '2222-1111-1111-1111']);});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: _isUnderWork? 8:10),
                child: CommonWidget.sectionTitleBuilder(
                    '${locale.txtQRScannedLabeledCount}: ${_scannedQrCodes.length}'
                ),
              ),
              Spacer(),
              Visibility(
                child: Container(
                  height: 32.0,
                  margin: EdgeInsets.only(right: 13),
                  child: GradientButton(
                    text: locale.txtSeeList,
                    onPressed: () => _showScannedQrCodeList(),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 32.0,
                  ),
                ),
                visible: _scannedQrCodes.length > 0,
              ),
            ],
          ),
          Flexible(child: _sectionQRCodeScanner(),),
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
      _showToast(locale.txtAlreadyScannedQRCode);
      _resumeCamera();
      return;
    }

    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      _resumeCamera();
      return;
    }

    setState(() => loadingState = LoadingState.LOADING);
    CommonWidget.showLoader(context, cancelable: true);
    if(_myIMEI == null) _myIMEI = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = _myIMEI;
    params[Params.ORDER_ID] = _orderItem.orderId;
    params[Params.QR_CODE] = qrCode;

    final response = await HttpUtil.get(HttpUtil.CHECK_PACKING_QR_CODE, params: params);
    Navigator.of(context).pop();
    _resumeCamera();

    if (response.statusCode != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      _showToast(locale.errorServerIsNotAvailable);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
//    final msg = responseMap['msg'];
    if(code == PackingQrCodeStatus.NOT_ISSUED) {
      setState(() => loadingState = LoadingState.ERROR);
      _showToast(locale.txtScannedQRCodeIsNotAvailable);
      return;
    }

    if(code == PackingQrCodeStatus.REGISTERED) {
      _showToast(locale.txtAlreadyScannedQRCode);
      //return;
    }

    setState(() => _scannedQrCodes.add(_qrText));
    _showToast(locale.txtScanned1QRCode, error: false);
  }

  _showScannedQrCodeList() async {
    ToastUtil.clear();
    final List resultList = await Navigator.of(context).push(
        MaterialPageRoute<List>(builder: (BuildContext context) {
          return Step4QrCodeListDialog(items: _scannedQrCodes.toList(),);
        },
            fullscreenDialog: true
        ));

    if (resultList != null) {
      setState(() => _scannedQrCodes.removeAll(resultList));
//      resultList.add('1111121323344445355');
      String msg = 'QRコード :\n${resultList.join(', \n')}\nを削除しました。';
      double verticalMargin = 220 - 20 - (resultList.length * 10.0);
      _showToast(msg, isDelete: true, verticalMargin: verticalMargin);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  _showToast(
      String msg, {
        error = true,
        fromTop = false,
        isDelete = false,
        double verticalMargin: 220,
      }) {
    final icon = AppIcons.loadIcon(
        error? isDelete? AppIcons.icDelete : AppIcons.icError : AppIcons.icLike,
        color: Colors.white, size: 16.0
    );
    ToastUtil.show(
        context, msg,
        icon: icon,
        fromTop: fromTop, verticalMargin: verticalMargin, error: error,
        duration: Duration(seconds: 3),
    );
  }

}