import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class ConfirmationDialog {
  final BuildContext context;
  final String title;
  final String msg;
  final Color msgTxtColor;
  final String confirmBtnTxt;
  final Function onConfirm;
  final Function onCancel;
  final bool closeOnConfirm;
  final bool cancelable;

  ConfirmationDialog(
      this.context,
      this.title,
      this.msg,
      this.confirmBtnTxt,
      this.onConfirm,
    {this.onCancel, 
      this.msgTxtColor = Colors.black, 
      this.closeOnConfirm = true, 
      this.cancelable = true,}
  );

  Text _buildText(String txt, Color color, double size) {
    return Text(
      txt,
      style: TextStyle(color: color, fontSize: size),
      textAlign: TextAlign.center,
    );
  }
  
  _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GradientButton(
          text: O2OLocalizations.of(context).txtCancel,
          txtColor: Colors.black,
          gradient: AppColors.btnGradientLight,
          onPressed: () {
            Navigator.of(context).pop();
            if(onCancel != null) onCancel();
          },
        ),
        GradientButton(
          text: confirmBtnTxt,
          onPressed: () {
            if(closeOnConfirm) Navigator.of(context).pop();
            onConfirm();
          },
          padding: EdgeInsets.symmetric(
              horizontal: confirmBtnTxt.length > 4? 16.0 : 36.0,
              vertical: 5.0
          ),
          showIcon: true,
        ),
      ],
    );
  }

  _bodyBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonWidget.buildDialogHeader(context, title),
        Padding(
          padding: EdgeInsets.all(13),
          child: _buildText(msg, msgTxtColor, 14.0),
        ),
        _buildActionButtons(),
        Padding(padding: EdgeInsets.only(bottom: 10),),
      ],
    );
  }

  show() {
    showDialog(
        context: context,
        barrierDismissible: cancelable,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                onWillPop: () async => cancelable,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: _bodyBuilder(),
                ),
              );
            },
          );
        });
  }
}