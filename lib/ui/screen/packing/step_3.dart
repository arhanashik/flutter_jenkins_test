import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
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

  _buildTopTitle() {
    return Container(
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
    );
  }

  _buildTopMessage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorF1F1F1,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.black12,),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0,),
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
            children: [
              CommonWidget.textSpanBuilder(
                  '商品の数、大きさに応じて ', color: AppColors.colorBlueDark,
                  bold: true, fontSize: 14.0
              ),
              CommonWidget.textSpanBuilder('使用する\n袋の数と配送ラベルの枚数を増やして下さい。',),
            ]
        ),
      ),
    );
  }

  _buildCurrentLabel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorF1F1F1,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.black12,),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 36),
      padding: EdgeInsets.symmetric(vertical: 13.0,),
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(fontSize: 12, color: Colors.black, height: 1.4),
            children: [
              CommonWidget.textSpanBuilder('この場合、配送ラベルは2枚必要です。',),
            ]
        ),
      ),
    );
  }

  _buildActionButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GradientButton(
            text: locale.txtGoToQrCodeScanner,
            onPressed: () => onNextScreen(),
            showIcon: true,
          ),
          GradientButton(
            text: locale.txtGoBack,
            onPressed: () => _returnToPreviousStep(),
            gradient: AppColors.btnGradientLight,
            txtColor: Colors.black,
            showIcon: true,
            icon: Icon(
              Icons.arrow_back_ios, color: Colors.black, size: 14,
            ),
          ),
        ],
      ),
    );
  }

  _bodyBuilder() {
    return ListView (
      children: <Widget>[
        _buildTopTitle(),
        _buildTopMessage(),
        AppImages.imgLabelInstruction,
        _buildCurrentLabel(),
        _buildActionButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: _bodyBuilder(),
    );
  }

}