import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';

class Step3Screen extends StatefulWidget {

  Step3Screen(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  @override
  _Step3ScreenState createState() => _Step3ScreenState(onPrevScreen, onNextScreen);
}

class _Step3ScreenState extends BaseState<Step3Screen> {

  _Step3ScreenState(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  _returnToPreviousStep() {
    ConfirmationDialog(
      context,
      locale.txtReturnToPreviousStep,
      locale.msgReturnToPreviousStep,
      locale.txtOk,
      onPrevScreen,
    ).show();
  }

  TextSpan _textSpanBuilder(
      String text, {
        Color color = Colors.black,
        bool bold = false
      }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: bold? FontWeight.bold: FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: ListView (
        children: <Widget>[
          Container(
            color: AppColors.colorBlue,
            padding: EdgeInsets.symmetric(vertical: 10.0,),
            alignment: Alignment.center,
            child: Text(
              locale.txtConceptOfLabel,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.colorF1F1F1,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0,),
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    _textSpanBuilder('商品の数、大きさに応じて', color: AppColors.colorBlueDark, bold: true),
                    _textSpanBuilder('使用する袋の数と配送ラベルの桁数を増やして下さい。',),
                  ]
              ),
            ),
          ),
          AppImages.imgLabelInstruction,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GradientButton(
                  text: locale.txtGoToQrCodeScanner,
                  onPressed: () => onNextScreen(),
                  showIcon: true,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GradientButton(
                text: locale.txtGoBack,
                onPressed: () => _returnToPreviousStep(),
                gradient: AppColors.btnGradientLight,
                txtColor: Colors.black,
                showIcon: true,
                icon: Icon(
                  Icons.arrow_back_ios, color: Colors.black, size: 14,
                ),
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

}