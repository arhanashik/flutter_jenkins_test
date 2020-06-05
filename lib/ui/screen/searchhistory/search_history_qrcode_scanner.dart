import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/response/search_history_response.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/scanner/full_screen_scanner_overlay_shape.dart';
import 'package:o2o/ui/screen/searchhistory/search_history.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SearchHistoryQrCodeScannerScreen extends StatefulWidget {
  SearchHistoryQrCodeScannerScreen({Key key}) : super(key: key);

  @override
  _SearchHistoryQrCodeScannerScreenState createState() => _SearchHistoryQrCodeScannerScreenState();
}

class _SearchHistoryQrCodeScannerScreenState extends BaseState<SearchHistoryQrCodeScannerScreen> {

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
        overlay: FullScreenScannerOverlayShape(
          borderColor: AppColors.colorBlue,
          borderRadius: 0,
          borderLength: 13,
          borderWidth: 5,
          cutOutWidth: 180,
          cutOutHeight: 180,
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
                  margin: EdgeInsets.only(right: 16,bottom: 10),
                  child: _flashOn ? AppImages.icFlushOn : AppImages.icFlushOff,
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
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBar (
        title: '',
        navigationIcon: AppImages.loadSizedImage(
            AppImages.icStopUrl, height: 32.0, width: 28.0, color: Colors.white
        ),
        iconColor: Colors.white,
        background: Colors.transparent,
        menu: InkWell(
          child: AppImages.loadSizedImage(
            AppImages.icSearchQrCodeUrl, height: 32.0, width: 71.0, color: Colors.white
        ),
          onTap: () {
            _qrCode = '';
            _routeToSearchHistory();
          },
        ),
        onTapNavigation: () => Navigator.pop(context),
      ),
      backgroundColor: AppColors.background,
      body: _bodyBuilder(),
    );
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
    Navigator.of(context).pop({Params.QR_CODE: _qrCode});
  }

  void _searchQrCode() async {
    CommonWidget.showLoader(context);
    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.QR_CODE] = _qrCode;

    final toastMargin = MediaQuery.of(context).size.height/2 - 32;

    String url = HttpUtil.SEARCH_HISTORY_BY_QR_CODE;
    final response = await HttpUtil.get(url, params: params);
    Navigator.of(context).pop();
    _resumeCamera();
    if (response.statusCode != HttpCode.OK) {
      _showToast(
          locale.errorServerIsNotAvailable, verticalMargin: toastMargin
      );
      return;
    }
    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code == HttpCode.OK) {
      final data = responseMap[Params.DATA];
      final searchResults = data.map(
              (data) => SearchHistoryResponse.fromJson(data)
      ).toList();

      if (searchResults.isNotEmpty) {
        _routeToSearchHistory();
        return;
      }
    }

    _showToast(
        'このQRコードに紐付く\n履歴がありません。', verticalMargin: toastMargin
    );
  }

  _routeToSearchHistory() async {
//    _pauseCamera();
//    await Navigator.of(context).push(
//      MaterialPageRoute<dynamic>(
//        builder: (BuildContext context) => SearchHistoryScreen(
//          searchQuery: _qrCode,
//          hint: locale.hintSearchByQrCode,
//          type: SearchType.QR_CODE,
//        ),
//      ),
//    );
//    _resumeCamera();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchHistoryScreen(
          searchQuery: _qrCode,
          hint: locale.hintSearchByQrCode,
          type: SearchType.QR_CODE,
        ),
      ),
    );
  }

  _showToast(
      String msg, {
        error = true,
        fromTop = true,
        verticalMargin: 150
      }) {
    final icon = AppIcons.loadIcon (
        error? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    ToastUtil.show(
        context, msg,
        icon: icon,
        fromTop: fromTop, verticalMargin: verticalMargin, error: error
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

}