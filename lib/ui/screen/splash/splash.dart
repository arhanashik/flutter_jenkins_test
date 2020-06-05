import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/home.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/loader/color_loader.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/util/helper/device_util.dart';
import 'package:o2o/util/lib/fcm/fcm_manager.dart';
import 'package:o2o/util/lib/remote/http_util.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseState<SplashScreen> {

  @override
  void onConnectionChanged(bool isConnected) {
    super.onConnectionChanged(isConnected);
    if(isConnected) _checkImei();
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 1500), () {
      _checkImei();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: CommonWidget.circledTextBuilder(
                text: locale.splashMsg, radius: 83
            ),
          ),
          Container (
            height: 120.0,
            child: Visibility(
              child: ColorLoader(),
              visible: loadingState == LoadingState.LOADING,
            ),
          ),
          Container(
            width: 140.0,
            margin: EdgeInsets.only(bottom: 16.0),
            child: Visibility(
              child: GradientButton(
                text: '更新する', showIcon: true, onPressed: () => _checkImei(),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
              ),
              visible: loadingState == LoadingState.ERROR,
            ),
          ),
        ],
      )
    );
  }

  _checkImei() async {
    if(loadingState == LoadingState.OK) return;

    if(!isOnline) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    setState(() => loadingState = LoadingState.LOADING);

    //Read and save the device serial number
    String serial = await DeviceUtil.getSerialNumber();
    await PrefUtil.save(PrefUtil.SERIAL_NUMBER, serial);

    bool loggedIn = await _login();
    if(!loggedIn) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    bool tokenUpdated = await _updateFcmToken();
    if(!tokenUpdated) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    setState(() => loadingState = LoadingState.OK);
    _goToNextScreen();
  }

  Future<bool> _login() async {
    String serial = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);

    final params = HashMap();
    params[Params.SERIAL] = serial;
    final response = await HttpUtil.get(HttpUtil.LOGIN, params: params);
    if (response.statusCode != HttpCode.OK) {
      SnackbarUtil.show(
        context,
        locale.errorServerIsNotAvailable,
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return false;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code == HttpCode.NOT_FOUND || code != HttpCode.OK) {
      SnackbarUtil.show(
        context,
        locale.errorDeviceNotAvailable,
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return false;
    }
    final data = responseMap[Params.DATA];
    final String deviceName = data[Params.DEVICE_NAME];
    final String storeName = data[Params.STORE_NAME];
    print('deviceName: $deviceName, storeName: $storeName');
    if(deviceName == null || deviceName.isEmpty || storeName == null || storeName.isEmpty) {
      SnackbarUtil.show(
        context,
        locale.errorCannotGetDeviceInfo,
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return false;
    }
    await PrefUtil.save(PrefUtil.DEVICE_NAME, deviceName);
    await PrefUtil.save(PrefUtil.STORE_NAME, storeName);

    return true;
  }

  Future<bool> _updateFcmToken() async {
    String serial = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);

    //Read and save the fcm notification token
    final fcmManager = FcmManager();
    await fcmManager.init();
    final String fcmToken = await fcmManager.getFcmToken();
    if(fcmToken == null || fcmToken.isEmpty) {
      SnackbarUtil.show(
        context,
        locale.errorCannotRegisterDevice,
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return false;
    }

    final oldFcmToken = await PrefUtil.read(PrefUtil.FCM_TOKEN);
    if(oldFcmToken == null || oldFcmToken.isEmpty || fcmToken != oldFcmToken) {
      final params = HashMap();
      params[Params.SERIAL] = serial;
      params[Params.TOKEN] = fcmToken;

      final response = await HttpUtil.post(HttpUtil.UPDATE_FCM_TOKEN, params);
      if (response.statusCode != HttpCode.OK) {
        SnackbarUtil.show(
          context,
          locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,),
          background: Colors.redAccent,
        );
        return false;
      }

      final responseMap = json.decode(response.body);
      final code = responseMap[Params.CODE];
      if(code != HttpCode.OK) {
        SnackbarUtil.show(
          context,
          locale.errorCannotRegisterDevice,
          icon: Icon(Icons.error, color: Colors.white,),
          background: Colors.redAccent,
        );
        return false;
      }

      await PrefUtil.save(PrefUtil.FCM_TOKEN, fcmToken);
    }

    return true;
  }

  _goToNextScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
    );
  }
}
