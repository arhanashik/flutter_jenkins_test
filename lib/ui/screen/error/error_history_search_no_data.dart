import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';

class HistorySearchNoDataErrorScreen extends StatefulWidget {
  HistorySearchNoDataErrorScreen({
    Key key,
  }): super(key: key);

  @override
  _HistorySearchNoDataErrorScreenState createState() => _HistorySearchNoDataErrorScreenState();
}

class _HistorySearchNoDataErrorScreenState extends BaseState<HistorySearchNoDataErrorScreen> {

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
        margin: EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        child: Text(
          locale.errorMsgNoHistorySearchData,
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _bodyBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 13.0, top: 13.0,),
          child: CommonWidget.sectionTitleBuilder('検索結果候補'),
        ),
        _buildMessage(),
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
}