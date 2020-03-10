import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_item_chooser_dialog.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/HttpUtil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Step4Screen extends StatefulWidget {

  Step4Screen(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  @override
  _Step4ScreenState createState() => _Step4ScreenState(onPrevScreen, onNextScreen);
}

class _Step4ScreenState extends BaseState<Step4Screen> {

  _Step4ScreenState(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRCodeScanner');
  var qrText = "";
  QRViewController controller;
  bool flashOn = false;
  final _scannedQrCodes = HashSet<String>();

  Container _sectionTitleBuilder(title) {
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
    );
  }

  _returnToPreviousStep() {
    ConfirmationDialog(
      context,
      locale.txtReturnToPreviousStep,
      locale.msgReturnToPreviousStep,
      locale.txtOk,
      onPrevScreen,
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
            onPressed: () => onNextScreen(_scannedQrCodes.toList()),
            showIcon: true,
          ),
        ],
      ),
    );
  }

  _showScannedQrCodeList() async {
    final List resultList = await Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenItemChooserDialog(items: _scannedQrCodes.toList(),);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      setState(() => _scannedQrCodes.removeAll(resultList));

      ToastUtil.show(
          context,
          '${resultList.join(',')} を削除しました。',
        icon: Icon(Icons.delete,),
      );
    }
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
                  padding: 10.0,
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
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        _pauseCamera();
        _checkQrProduct(qrText);
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

  void _resumeCamera() {
    controller?.resumeCamera();
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

    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['qrCode'] = qrCode;

    final response = await HttpUtil.postReq(AppConst.CHECK_PACKING_QR_CODE, requestBody);
    print('code: ${response.statusCode}');
    Navigator.of(context).pop();
    _resumeCamera();

    if (response.statusCode != 200) {
      ToastUtil.show(
          context, 'Please try again',
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      return;
    }

    print('body: ${response.body}');
    final responseCode = json.decode(response.body);
    if(responseCode['resultCode'] == PackingQrCodeStatus.NOT_ISSUED) {
      ToastUtil.show(
          context, 'No Product from HTKK $qrCode',
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      return;
    }

    if(responseCode['resultCode'] == PackingQrCodeStatus.REGISTERED) {
      ToastUtil.show(
          context, 'Product already registered with $qrCode',
          icon: Icon(Icons.error, color: Colors.white,),
          verticalMargin: 200, error: true
      );
      return;
    }

    setState(() => _scannedQrCodes.add(qrText));
    ToastUtil.show(context, locale.txtScanned1QRCode, verticalMargin: 200,);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

}