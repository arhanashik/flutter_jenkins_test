import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/search_history.dart';
import 'package:o2o/ui/screen/scanner/full_screen_scanner_overlay_shape.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class ScannerScreen extends StatefulWidget {
  ScannerScreen({
    Key key,
    @required this.navigationIcon,
    this.menu,
    this.onTapNavigation,
  }) : super(key: key);
  final Widget navigationIcon;
  final Widget menu;
  final Function onTapNavigation;

  @override
  _ScannerScreenState createState() => _ScannerScreenState(
    navigationIcon, menu,
  );
}

class _ScannerScreenState extends BaseState<ScannerScreen> {

  _ScannerScreenState(this._navigationIcon, this._menu,);
  final Widget _navigationIcon;
  final Widget _menu;

  final GlobalKey _qrKey = GlobalKey(debugLabel: 'SCANNER');
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
        overlay: FullScreenScannerOverlayShape(
          borderColor: AppColors.colorBlue,
          borderRadius: 0,
          borderLength: 13,
          borderWidth: 5,
          cutOutWidth: 180,
          cutOutHeight: 120,
        ),
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
                  margin: EdgeInsets.only(right: 16,bottom: 5),
                  child: _flashOn ? AppImages.icFlushOn : AppImages.icFlushOff,
                ),
                onTap: _toggleFlush,
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(right: 16,bottom: 16),
                  child: AppImages.icFullScreenExit,
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.blueGradient)
                ),
                alignment: Alignment.center,
                child: Text(
                  locale.msgReadBarcode,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
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
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBar(
        title: '',
        navigationIcon: _navigationIcon,
        background: Colors.transparent,
        menu: _menu,
        onTapNavigation: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.background,
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
      _exitScannerWithResult();
//      _searchQrCode();
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