import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerScreen extends StatefulWidget {
  ScannerScreen({Key key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  O2OLocalizations locale;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'SCANNER');
  var qrText = "";
  QRViewController controller;
  bool flashOn = false;

  Stack _scannerViewStack() {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 16, top: 80),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Icon(
                    flashOn? Icons.flash_off : Icons.flash_on,
                    color: Colors.lightBlue,
                  ),
                  padding: EdgeInsets.all(2),
                ),
                onTap: _toggleFlush,
              ),
              Padding(padding: EdgeInsets.only(top: 16),),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Icon(
                    Icons.switch_camera,
                    color: Colors.lightBlue,
                  ),
                  padding: EdgeInsets.all(2),
                ),
                onTap: _flipCamera,
              ),
              Padding(padding: EdgeInsets.only(top: 16),),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Icon(
                    Icons.fullscreen_exit,
                    color: Colors.lightBlue,
                  ),
                  padding: EdgeInsets.all(2),
                ),
                onTap: () {
                  _pauseCamera();
                  _exitScannerWithResult();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _bodyBuilder() {
    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          _scannerViewStack(),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            color: Color(0xbb000000),
            padding: EdgeInsets.all(16),
            child: Text(
              locale.msgScanBarcodeExtended,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    locale = O2OLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 230, 242, 255),
      body: _bodyBuilder(),
    );
  }

  @override
  void setState(fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _pauseCamera();
      setState(() => qrText = scanData);
      _exitScannerWithResult();
    });
  }

  void _flipCamera() {
    controller?.flipCamera();
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

  void _exitScannerWithResult() {
    Navigator.of(context).pop({'qrCode': qrText});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

}