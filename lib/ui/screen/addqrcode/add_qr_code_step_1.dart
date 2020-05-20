import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/response/order_history_details_response.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/packing/step_4_scanner_overlay_shape.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddQrCodeStep1 extends StatefulWidget {

  AddQrCodeStep1(
      this.orderHistoryDetails,
      this.newQrCodes,
      this.onNextScreen
      );
  final OrderHistoryDetails orderHistoryDetails;
  final LinkedHashSet newQrCodes;
  final Function onNextScreen;

  @override
  _AddQrCodeStep1State createState() => _AddQrCodeStep1State();
}

class _AddQrCodeStep1State extends BaseState<AddQrCodeStep1> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'AddQRCodeScanner');
  var _qrText = "";
  QRViewController _controller;
  bool _flashOn = false;

  Container _sectionQRCodeScanner() {
    return Container(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            child: QRView(
              key: qrKey,
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
              margin: EdgeInsets.only(right: 13, bottom: 13),
              child: _flashOn ? AppImages.icFlushOn : AppImages.icFlushOff,
            ),
            onTap: _toggleFlush,
          ),
        ],
      ),
    );
  }

  _buildControlBtn() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13.0),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GradientButton(
            text: 'ラベル記入へ進む',
            onPressed: () => widget.onNextScreen(widget.newQrCodes.toList()),
            showIcon: true,
            enabled: widget.newQrCodes.isNotEmpty,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final qrCodeCount = widget.orderHistoryDetails.qrCodes.length + widget.newQrCodes.length;

    return Container (
      color: Colors.white,
      child: Column (
        children: <Widget>[
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13.0,),
              alignment: Alignment.centerLeft,
              child: CommonWidget.sectionTitleBuilder('${locale.txtQRScannedLabeledCount}: $qrCodeCount'),
            ),
            flex: 1,
          ),
          Flexible(child:_sectionQRCodeScanner(), flex: 7,),
          Flexible(child: _buildControlBtn(), flex: 2,),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _qrText = scanData;
      _pauseCamera();
      _checkQrProduct(_qrText);
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
    if(widget.orderHistoryDetails.qrCodes.contains(qrCode)
        || widget.newQrCodes.contains(qrCode)) {
      _showToast(locale.txtAlreadyScannedQRCode);
      _resumeCamera();
      return;
    }

    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      _resumeCamera();
      return;
    }

    CommonWidget.showLoader(context, cancelable: true);
    String serial = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = serial;
    params[Params.ORDER_ID] = widget.orderHistoryDetails.orderId;
    params[Params.QR_CODE] = qrCode;

    final response = await HttpUtil.get(HttpUtil.CHECK_PACKING_QR_CODE, params: params);
    Navigator.of(context).pop();
    _resumeCamera();

    if (response.statusCode != HttpCode.OK) {
      _showToast(locale.errorServerIsNotAvailable);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code == PackingQrCodeStatus.NOT_ISSUED) {
      _showToast(locale.txtScannedQRCodeIsNotAvailable);
      return;
    }

    if(code == PackingQrCodeStatus.REGISTERED) {
      _showToast(locale.txtAlreadyScannedQRCode);
      //return;
    }

    setState(() => widget.newQrCodes.add(_qrText));
    _showToast(locale.txtScanned1QRCode, error: false);
  }

  _showToast(
      String msg, {
        error = true,
        fromTop = false,
        double verticalMargin: 250,
      }) {
    final icon = AppIcons.loadIcon(
        error ? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    ToastUtil.show(
      context, msg,
      icon: icon,
      fromTop: fromTop,
      verticalMargin: verticalMargin,
      error: error,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

}