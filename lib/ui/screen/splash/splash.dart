import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/home.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/DeviceUtil.dart';
import 'package:o2o/util/HttpUtil.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseState<SplashScreen> {

  bool _splashTimeOver = false;
  bool _imeiRegistered = false;

  _buildBackground() {
    return BoxDecoration(color: AppColors.background,);
  }

  _registerImei() async {
    if(_imeiRegistered || !isOnline) return;

    String imei = await DeviceUtil.getIMEI();
    await PrefUtil.save(PrefUtil.IMEI, imei);

    /*
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    final response = await HttpUtil.postReq(AppConst.GET_INFO, requestBody);
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('message: ${response.message}');
      ToastUtil.showCustomToast(context, 'Server is not available. Please try again.');
      return;
    }

    print('body: ${response.body}');
    final responseMap = json.decode(response.body);
    await PrefUtil.save(PrefUtil.DEVICE_NAME, responseMap['deviceName']);
    await PrefUtil.save(PrefUtil.STORE_NAME, responseMap['storeName']);
    */
    _imeiRegistered = true;
    _goToNextScreen();
  }

  _goToNextScreen() async {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
    );
  }

  @override
  void onConnectionChanged(bool isConnected) {
    super.onConnectionChanged(isConnected);
    if(isConnected && _splashTimeOver) {
      _registerImei();
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 1500), () {
      _splashTimeOver = true;
      _registerImei();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: _buildBackground(),
        alignment: Alignment.center,
        child: CommonWidget.circledTextBuilder(
            text: locale.splashMsg, radius: 83
        ),
      ),
    );
  }
}
