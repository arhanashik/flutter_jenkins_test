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
    String imei = await DeviceUtil.getIMEI();
    await PrefUtil.save(PrefUtil.IMEI, imei);
    final String fcmToken = await FcmManager().getFcmToken();
    if(fcmToken == null || fcmToken.isEmpty) {
      setState(() => loadingState = LoadingState.ERROR);
      SnackbarUtil.show(
        context,
        'Fcm token not found',
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return;
    }
    final oldFcmToken = await PrefUtil.read(PrefUtil.FCM_TOKEN);
    if(oldFcmToken == null || oldFcmToken.isEmpty || fcmToken != oldFcmToken) {
      final params = HashMap();
      params['imei'] = imei;
      params['token'] = fcmToken;

      final response = await HttpUtil.post(HttpUtil.UPDATE_FCM_TOKEN, params);
      if (response.statusCode != HttpCode.OK) {
        setState(() => loadingState = LoadingState.ERROR);
        SnackbarUtil.show(
          context,
          locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,),
          background: Colors.redAccent,
        );
        return;
      }

      final responseMap = json.decode(response.body);
      final code = responseMap['code'];
      if(code != HttpCode.OK) {
        setState(() => loadingState = LoadingState.ERROR);
        SnackbarUtil.show(
          context,
          '端末Tokenはサーバーに登録するはできません。',
          icon: Icon(Icons.error, color: Colors.white,),
          background: Colors.redAccent,
        );
        return;
      }

      await PrefUtil.save(PrefUtil.FCM_TOKEN, fcmToken);
    }

    final params = HashMap();
    params['imei'] = imei;
    final response = await HttpUtil.get(HttpUtil.LOGIN, params: params);
    if (response.statusCode != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      SnackbarUtil.show(
        context,
        locale.errorServerIsNotAvailable,
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    if(code == HttpCode.NOT_FOUND) {
      setState(() => loadingState = LoadingState.ERROR);
      SnackbarUtil.show(
        context,
        '端末はサーバーにまだありません。',
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
      );
      return;
    }
    final String deviceName = responseMap['data']['deviceName'];
    final String storeName = responseMap['data']['storeName'];
    print('deviceName: $deviceName, storeName: $storeName');
//    if(deviceName.isEmpty || storeName.isEmpty) {
//      setState(() => loadingState = LoadingState.ERROR);
//      SnackbarUtil.show(
//        context,
//        '端末の情報は取得することができません。',
//        icon: Icon(Icons.error, color: Colors.white,),
//        background: Colors.redAccent,
//      );
//      return;
//    }
    await PrefUtil.save(PrefUtil.DEVICE_NAME, deviceName);
    await PrefUtil.save(PrefUtil.STORE_NAME, storeName);


    setState(() => loadingState = LoadingState.OK);
    _goToNextScreen();
  }

  _updateFcmToken() {

  }

  _goToNextScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
    );
  }
}
