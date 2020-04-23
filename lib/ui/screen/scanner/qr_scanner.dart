import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void QRScannerCreatedCallback(QRScannerController controller);

class QRScanner extends StatefulWidget {
  const QRScanner({
    @required Key key,
    @required this.onQRViewCreated,
    this.overlay,
  })  : assert(key != null),
        assert(onQRViewCreated != null),
        super(key: key);
  final QRScannerCreatedCallback onQRViewCreated;

  final ShapeBorder overlay;

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        _getPlatformQrView(),
        widget.overlay != null
            ? Container(
          decoration: ShapeDecoration(
            shape: widget.overlay,
          ),
        ) : Container(),
      ],
    );
  }

  Widget _getPlatformQrView() {
    Widget _platformQrView;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _platformQrView = AndroidView(
          viewType: 'net.touchcapture.qr.flutterqr/qrview',
          onPlatformViewCreated: _onPlatformViewCreated,
        );
        break;
      case TargetPlatform.iOS:
        _platformQrView = UiKitView(
          viewType: 'net.touchcapture.qr.flutterqr/qrview',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _CreationParams.fromWidget(0, 0).toMap(),
          creationParamsCodec: StandardMessageCodec(),
        );
        break;
      default:
        throw UnsupportedError(
            "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return _platformQrView;
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onQRViewCreated == null) {
      return;
    }
    widget.onQRViewCreated(QRScannerController._(id, widget.key));
  }
}

class _CreationParams {
  _CreationParams({this.width, this.height});

  static _CreationParams fromWidget(double width, double height) {
    return _CreationParams(
      width: width,
      height: height,
    );
  }

  final double width;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

class QRScannerController {
  static const scanMethodCall = "onRecognizeQR";

  final MethodChannel _channel;

  StreamController<String> _scanUpdateController = StreamController<String>();

  Stream<String> get scannedDataStream => _scanUpdateController.stream;

  QRScannerController._(int id, GlobalKey qrKey)
      : _channel = MethodChannel('net.touchcapture.qr.flutterqr/qrview_$id') {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      _channel.invokeMethod("setDimensions",
          {"width": renderBox.size.width, "height": renderBox.size.height});
    }
    _channel.setMethodCallHandler(
          (MethodCall call) async {
        switch (call.method) {
          case scanMethodCall:
            if (call.arguments != null) {
              _scanUpdateController.sink.add(call.arguments.toString());
            }
        }
      },
    );
  }

  void flipCamera() {
    _channel.invokeMethod("flipCamera");
  }

  void toggleFlash() {
    _channel.invokeMethod("toggleFlash");
  }

  void pauseCamera() {
    _channel.invokeMethod("pauseCamera");
  }

  void resumeCamera() {
    _channel.invokeMethod("resumeCamera");
  }

  void dispose() {
    _scanUpdateController.close();
  }
}