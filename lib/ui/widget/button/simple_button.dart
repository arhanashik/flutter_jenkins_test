import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {

  SimpleButton(
      this.title,
      this.txtColor,
      this.bgColor,
      this.onPressed,
      {this.padding = 36.0, this.enabled = true}
  );

  final String title;
  final Color txtColor;
  final Color bgColor;
  final Function onPressed;
  final double padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: padding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
      textColor: txtColor,
      color: bgColor,
      disabledColor: Colors.grey,
      child: Text(
        title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),
      ),
      onPressed: enabled? this.onPressed : null,
    );
  }
}