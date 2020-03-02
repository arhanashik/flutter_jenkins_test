import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/refresh_button.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';

class NoOrderListDataScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            locale.noTimeOrderData,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 64),
          child: Center(
            child: RefreshButton(locale.refreshOrderList, () {
              ToastUtil.showCustomToast(context, locale.refreshOrderList);
            }),
          ),
        ),
      ],
    );
  }
}
