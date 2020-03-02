import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/home/history/search_history.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScannerScreen extends StatefulWidget {
  QrCodeScannerScreen({Key key}) : super(key: key);

  @override
  _QrCodeScannerScreenState createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  O2OLocalizations locale;

  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QRCODESCANNER');
  var _qrCode = "";
  QRViewController _controller;
  bool _flashOn = false;

  _scannerViewStack() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: QRView(
        key: _qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  _bodyBuilder() {
    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          _scannerViewStack(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(right: 16,bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Icon(
                    _flashOn? Icons.flash_off : Icons.flash_on,
                    color: Colors.lightBlue,
                  ),
                  padding: EdgeInsets.all(2),
                ),
                onTap: _toggleFlush,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                color: AppColors.colorBlue,
                padding: EdgeInsets.all(16),
                child: Text(
                  locale.msgReadQRCode,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          )
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () => _searchQrCode(),
          ),
        ],
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
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _pauseCamera();
      setState(() => _qrCode = scanData);
//      _exitScannerWithResult();
      _searchQrCode();
    });
  }

  void _flipCamera() {
    _controller?.flipCamera();
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

  void _exitScannerWithResult() {
    Navigator.of(context).pop({'qrCode': _qrCode});
  }

  void _searchQrCode() {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchHistory(
          searchQuery: _qrCode,
          hint: locale.hintSearchByQrCode,
          type: SearchType.QR_CODE,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

}