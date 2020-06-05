import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class SelectNextStepDialog {
  final BuildContext context;
  final Function onConfirm;
  final Function onReportMissing;
  final Function onOther;

  SelectNextStepDialog({
    Key key,
    this.context,
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
      style: TextStyle(
          color: color, fontSize: size, decoration: TextDecoration.underline
      ),
      textAlign: TextAlign.center,
    );
  }

  _bodyBuilder() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonWidget.buildDialogHeader(
            context, locale.txtAllProductsPickingDone, fontSize: 14
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: _buildText(locale.txtSelectNextStep, Colors.black, 14.0),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GradientButton(
            text: locale.txtProceedToShippingPreparation,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            showIcon: true,
          ),
        ),
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: _buildUnderlineText(
                '！${locale.txtProvideMissingInfo}', Colors.black, 14.0
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            onReportMissing();
          },
        ),
        Container(
          height: 1,
          color: Colors.grey,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GradientButton(
            text: locale.txtPickAnotherOrder,
            onPressed: () {
              Navigator.of(context).pop();
              onOther();
            },
            showIcon: true,
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 10),)
      ],
    );
  }

  show() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                onWillPop: () async => false,
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
