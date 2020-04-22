import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';

class InputDialog {
  final BuildContext context;
  final String title;
  final String btnTxt;
  final Function onTxtChange;
  final Function onBtnTap;
  Function onCancel;

  String insertedCode = '';

  InputDialog(
      this.context,
      this.title,
      this.btnTxt,
      this.onBtnTap, {
        this.onTxtChange,
        this.onCancel,
  });

  show() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: CommonWidget.roundRectBorder(5.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        CommonWidget.buildDialogHeader(context, title, fontSize: 14.0),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              if(onCancel != null) onCancel();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.close, color: Colors.white,),
                            )
                        )
                      ],
                    ),
                    Container(
                      height: 48.0,
                      margin: EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          enabledBorder: CommonWidget.outlineBorder(
                              color: insertedCode.isEmpty
                                  ? AppColors.colorF1F1F1 : AppColors.colorBlue
                          ),
                          focusedBorder: CommonWidget.outlineBorder(
                              color: insertedCode.isEmpty
                                  ? AppColors.colorF1F1F1 : AppColors.colorBlue
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.colorBlueDark,
                          fontWeight: FontWeight.bold,
                        ),
                        autofocus: true,
                        onChanged: (text) {
                          stateSetter(() => insertedCode = text);
                          onTxtChange(text);
                        },
                      ),
                    ),
                    Container(
                      height: 48,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: GradientButton(
                        text: btnTxt,
                        onPressed: () => onBtnTap(insertedCode),
                        borderRadius: 24.0,
                        showIcon: true,
                        enabled: insertedCode.isNotEmpty,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 16),)
                  ],
                );
              },
            )
          );
        });
  }
}