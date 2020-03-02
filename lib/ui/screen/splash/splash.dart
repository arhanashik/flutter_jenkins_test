import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/home/home.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/DeviceUtil.dart';
import 'package:o2o/util/HttpUtil.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  _buildBackground() {
    return BoxDecoration(color: AppColors.background,);
  }

  _registerImei() async{
    String imei = await DeviceUtil.getIMEI();
    await PrefUtil.save(PrefUtil.IMEI, imei);

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

    _goToNextScreen();
  }

  _goToNextScreen() async{
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 1500), () => _registerImei());
  }

  Text _buildText(text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 24,
          color: AppColors.colorBlueDark,
        fontWeight: FontWeight.bold
      ),
      textAlign: TextAlign.center,
    );
  }

  Container _circledTextBuilder(text) {
    return Container(
      width: 166,
      height: 166,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: AppColors.btnGradient,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter
          ),
          borderRadius: BorderRadius.circular(83)
      ),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(75)
        ),
        child: Center(
          child: _buildText(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    O2OLocalizations local = O2OLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: _buildBackground(),
        alignment: Alignment.center,
        child: _circledTextBuilder(local.splashMsg),
      ),
    );
  }
}
