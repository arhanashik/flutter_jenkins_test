import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/util/helper/device_util.dart';

class ErrorScreen extends StatefulWidget {
  ErrorScreen({
    Key key,
    @required this.errorMessage,
    @required this.btnText,
    this.onClickBtn,
    this.showHelpTxt = false
  }): super(key: key);
  final String errorMessage;
  final String btnText;
  final Function onClickBtn;
  final bool showHelpTxt;

  @override
  _ErrorScreenState createState() => _ErrorScreenState(
    errorMessage, btnText, onClickBtn, showHelpTxt
  );
}

class _ErrorScreenState extends BaseState<ErrorScreen> {

  _ErrorScreenState(
    this.errorMessage,
    this.btnText,
    this.onClickBtn,
    this.showHelpTxt);
  final String errorMessage;
  final String btnText;
  final Function onClickBtn;
  final bool showHelpTxt;

  String _deviceName = '';
  String _storeName = '';

  _buildMessage() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  _buildHelpTexts() {
    return Column(
      children: <Widget>[
        Text(
          locale.txtContactUsPart1,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black, height: 1.6),
        ),
        InkWell(
          child: Text(
            locale.txtContactUsPart2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black, height: 1.6),
          ),
          onTap: () => _makePhoneCall('12345'),
        ),
        InkWell(
          child: Text(
            locale.txtContactUsPart3,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black, height: 1.6),
          ),
          onTap: () => _makePhoneCall('67890'),
        ),
        _deviceName.isEmpty? Container() : Text(
          locale.txtContactUsPart4.replaceAll('-imei-', _deviceName),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black, height: 1.6),
        ),
      ],
    );
  }

  _bodyBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildMessage(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: GradientButton(
            text: btnText,
            showIcon: true,
            onPressed: () => onClickBtn(),
          ),
        ),
        showHelpTxt? _buildHelpTexts() : Spacer(),
        Visibility(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              locale.appInfo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          visible: !showHelpTxt,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _readDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _bodyBuilder(),
    );
  }

  _readDeviceInfo() async {
    String deviceName = await PrefUtil.read(PrefUtil.DEVICE_NAME);
    String storeName = await PrefUtil.read(PrefUtil.STORE_NAME);

    setState(() { 
      _deviceName = deviceName;
      _storeName = storeName;
    });
  }

  _makePhoneCall(String phoneNum) {
    ConfirmationDialog(
        context,
        '電話する',
        '$phoneNum に電話しますか？',
        '電話する', () => DeviceUtil.makePhoneCall(phoneNum)
    ).show();
  }
}