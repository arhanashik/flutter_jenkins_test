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
  final bool closeOnConfirm;

  ConfirmationDialog(
      this.context,
      this.title,
      this.msg,
      this.confirmBtnTxt,
      this.onConfirm,
    {this.msgTxtColor = Colors.black,
    this.closeOnConfirm = true, }
  );

  Text _buildText(String txt, Color color, double size) {
    return Text(
      txt,
      style: TextStyle(color: color, fontSize: size),
      textAlign: TextAlign.center,
    );
  }

  show() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonWidget.buildDialogHeader(context, title),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildText(msg, msgTxtColor, 14.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GradientButton(
                      text: O2OLocalizations.of(context).txtCancel,
                      txtColor: Colors.black,
                      gradient: AppColors.btnGradientLight,
                      onPressed: () => Navigator.of(context).pop(),
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
                ),
                Padding(padding: EdgeInsets.only(bottom: 10),),
              ],
            ),
          );
        });
  }
}