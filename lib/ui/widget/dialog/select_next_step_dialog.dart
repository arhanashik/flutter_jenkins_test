import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';

class SelectNextStepDialog {
  final BuildContext context;
  final String title;
  final String msg;
  final String warning;
  final String confirmBtnTxt;
  final String otherButtonText;
  final Function onConfirm;
  final Function onReportMissing;
  final Function onOther;

  SelectNextStepDialog({
    Key key,
    this.context,
    this.title,
    this.msg,
    this.warning,
    this.confirmBtnTxt,
    this.otherButtonText,
    this.onConfirm,
    this.onReportMissing,
    this.onOther,
  });

  Text _buildText(String txt, Color color, double size) {
    return Text(
      txt,
      style: TextStyle(color: color, fontSize: size,),
      textAlign: TextAlign.center,
    );
  }

  Text _buildUnderlineText(String txt, Color color, double size) {
    return Text(
      txt,
      style: TextStyle(color: color, fontSize: size, decoration: TextDecoration.underline),
      textAlign: TextAlign.center,
    );
  }

  show() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonWidget.buildDialogHeader(context, title, fontSize: 14),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildText(msg, Colors.black, 14.0),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GradientButton(
                    text: confirmBtnTxt,
                    onPressed: () {
                      onConfirm();
                    },
                    showIcon: true,
                  ),
                ),
                InkWell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: _buildUnderlineText('！$warning', Colors.black, 14.0),
                  ),
                  onTap: () => onReportMissing(),
                ),
                Container(
                  height: 1,
                  color: Colors.grey,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GradientButton(
                    text: otherButtonText,
                    onPressed: () {
                      onOther();
                    },
                    showIcon: true,
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 10),)
              ],
            ),
          );
        });
  }
}
