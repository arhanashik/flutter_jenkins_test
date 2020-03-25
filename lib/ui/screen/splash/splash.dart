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
            margin: EdgeInsets.all(16.0),
            child: Visibility(
              child: GradientButton(
                text: '更新する', showIcon: true, onPressed: () => _checkImei(),
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

    final params = HashMap();
    params['imei'] = imei;
    final response = await HttpUtil.get(HttpUtil.LOGIN, params: params);
    if (response.statusCode != 200) {
      print('message: ${response.message}');
      setState(() => loadingState = LoadingState.ERROR);
      SnackbarUtil.show(
        context,
        'Server is not available. Please try again.',
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
        durationInSec: 5,
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
        durationInSec: 5,
      );
      return;
    }
    final String deviceName = responseMap['data']['deviceName'];
    final String storeName = responseMap['data']['storeName'];
    print('deviceName: $deviceName, storeName: $storeName');
    if(deviceName.isEmpty || storeName.isEmpty) {
      setState(() => loadingState = LoadingState.ERROR);
      SnackbarUtil.show(
        context,
        '端末の情報は取得することができません。',
        icon: Icon(Icons.error, color: Colors.white,),
        background: Colors.redAccent,
        durationInSec: 5,
      );
      return;
    }
    await PrefUtil.save(PrefUtil.DEVICE_NAME, deviceName);
    await PrefUtil.save(PrefUtil.STORE_NAME, storeName);


    setState(() => loadingState = LoadingState.OK);
    _goToNextScreen();
  }

  _goToNextScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
    );
  }
}
