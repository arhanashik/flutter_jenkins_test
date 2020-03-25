import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/screen/packing/step_4_qr_code_list_dialog.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Step4Screen extends StatefulWidget {

  Step4Screen(this.qrCodes, this.onPrevScreen, this.onNextScreen);
  final LinkedHashSet<String> qrCodes;
  final Function onPrevScreen;
  final Function onNextScreen;

  @override
  _Step4ScreenState createState() => _Step4ScreenState(
      qrCodes, onPrevScreen, onNextScreen
  );
}

class _Step4ScreenState extends BaseState<Step4Screen> {

  _Step4ScreenState(this._scannedQrCodes, this._onPrevScreen, this._onNextScreen);
  final LinkedHashSet<String> _scannedQrCodes;
  final Function _onPrevScreen;
  final Function _onNextScreen;

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
          height: 275,
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
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
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
    if(!isOnline) {
      ToastUtil.show(
          context, 'Connect to internet first',
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      _resumeCamera();
      return;
    }

//    CommonWidget.showLoader(context, cancelable: true);
//    String imei = await PrefUtil.read(PrefUtil.IMEI);
//    final requestBody = HashMap();
//    requestBody['imei'] = imei;
//    requestBody['qrCode'] = qrCode;
//
//    final response = await HttpUtil.postReq(AppConst.CHECK_PACKING_QR_CODE, requestBody);
//    print('code: ${response.statusCode}');
//    Navigator.of(context).pop();
//    _resumeCamera();
//
//    if (response.statusCode != 200) {
//      ToastUtil.show(
//          context, 'Please try again',
//          icon: Icon(Icons.error, color: Colors.white,),
//          verticalMargin: 200, error: true
//      );
//      return;
//    }

//    print('body: ${response.body}');
//    final responseCode = json.decode(response.body);
//    if(responseCode['resultCode'] == PackingQrCodeStatus.NOT_ISSUED) {
//      ToastUtil.show(
//          context, 'No Product from HTKK $qrCode',
//          icon: Icon(Icons.error, color: Colors.white,),
//          verticalMargin: 200, error: true
//      );
//      return;
//    }
//
//    if(responseCode['resultCode'] == PackingQrCodeStatus.REGISTERED) {
//      ToastUtil.show(
//          context, 'Product already registered with $qrCode',
//          icon: Icon(Icons.error, color: Colors.white,),
//          verticalMargin: 200, error: true
//      );
//      return;
//    }

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