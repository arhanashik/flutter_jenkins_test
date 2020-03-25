import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

class GradientButton extends StatelessWidget {

  GradientButton({
    this.text,
    this.txtColor = Colors.white,
    this.disableTxtColor = Colors.white,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w600,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    this.gradient = AppColors.btnGradient,
    this.borderRadius = 18.0,
    this.enabled = true,
    this.showIcon = false,
    this.icon = const Icon(
      Icons.play_circle_filled, color: Colors.white, size: 18,
    ),
    this.iconPadding = const EdgeInsets.only(right: 10.0),
  });

  final String text;
  final Color txtColor;
  final Color disableTxtColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Function onPressed;
  final EdgeInsets padding;
  final List<Color> gradient;
  final double borderRadius;
  final bool enabled;
  final bool showIcon;
  final Icon icon;
  final EdgeInsets iconPadding;

  @override
  Widget build(BuildContext context) {

//    double calculatedPadding = showIcon? padding - 5.0 : padding;
//    double paddingVertical = showIcon? 5.0 : 11.0;

    return RaisedButton(
      onPressed: enabled? () =>  onPressed() : null,
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      disabledColor: Colors.grey,
      disabledTextColor: Colors.white70,
      elevation: 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius),),
          gradient: LinearGradient(colors: enabled? gradient : AppColors.disabledGradient,),
        ),
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            showIcon? Padding(padding: iconPadding, child: icon,) : Container(),
            Text(
                text,
                style: TextStyle(
                    color: enabled? txtColor : disableTxtColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight
                )
            )
          ],
        ),
      ),
    );
  }
}