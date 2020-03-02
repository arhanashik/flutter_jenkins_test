import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/input/pin_entry.dart';

class Step2Screen extends StatefulWidget {

  Step2Screen(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  @override
  _Step2ScreenState createState() => _Step2ScreenState(onPrevScreen, onNextScreen);
}

class _Step2ScreenState extends BaseState<Step2Screen> {

  _Step2ScreenState(this.onPrevScreen, this.onNextScreen);
  final Function onPrevScreen;
  final Function onNextScreen;

  String _pinCode = '';

  _returnToPreviousStep() {
    ConfirmationDialog(
      context,
      locale.txtReturnToPreviousStep,
      locale.msgReturnToPreviousStep,
      locale.txtOk,
      onPrevScreen,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(top: 24, left: 16, right: 16),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 48.0,
            child: PinEntry(
              fieldWidth: 48.0,
              fontSize: 20.0,
              showFieldAsBox: true,
              onChange: (String pin) {
                setState(() => _pinCode = pin);
              },
              onSubmit: (String pin) {
                setState(() => _pinCode = pin);
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              ),
              GradientButton(
                text: locale.txtGoToLabelPreparation,
                onPressed: () => onNextScreen(_pinCode),
                enabled: _pinCode.length == 4,
                showIcon: true,
              ),
            ],
          )
        ],
      ),
    );
  }
}