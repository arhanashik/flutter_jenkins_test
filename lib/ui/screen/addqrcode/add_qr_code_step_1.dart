import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/button/simple_button.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddQrCodeStep1 extends StatefulWidget {

  AddQrCodeStep1(this.qrCodes, this.onNextScreen);
  final List<String> qrCodes;
  final Function onNextScreen;

  @override
  _AddQrCodeStep1State createState() => _AddQrCodeStep1State(
      HashSet.from(qrCodes), onNextScreen
  );
}

class _AddQrCodeStep1State extends BaseState<AddQrCodeStep1> {

  _AddQrCodeStep1State(this._qrCodes, this.onNextScreen);
  final HashSet<String> _qrCodes;
  final Function onNextScreen;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'AddQRCodeScanner');
  var qrText = "";
  QRViewController controller;
  bool flashOn = false;

  Container _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16,),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Container _sectionQRCodeScanner() {
    return Container(
      constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
      margin: EdgeInsets.only(bottom: 60),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
//            color: Colors.lightBlue,
            child: QRView(
              key: qrKey,
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
                flashOn ? Icons.flash_off : Icons.flash_on,
                color: Colors.lightBlue,
              ),
              padding: EdgeInsets.all(2),
            ),
            onTap: _toggleFlush,
          ),
        ],
      ),
    );
  }

  _buildControlBtn() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GradientButton(
            text: locale.txtCompleteShippingPreparation,
            onPressed: () => onNextScreen(_qrCodes.toList()),
            showIcon: true,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Stack (
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: <Widget>[
              _sectionQRCodeScanner(),
              _sectionTitleBuilder('${locale.txtQRScannedLabeledCount}: ${_qrCodes.length}'),
            ],
          ),
          _buildControlBtn(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        _qrCodes.add(qrText);
        ToastUtil.show(context, locale.txtScanned1QRCode);
      });
    });
  }

  void _toggleFlush() {
    controller?.toggleFlash();
    setState(() => flashOn = !flashOn);
  }

  void _pauseCamera() {
    controller?.pauseCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

}