import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {

  RefreshButton(this.title, this.onPressed);

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
      color: Colors.lightBlue,
      textColor: Colors.white,
      child: Text(
        title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
      ),
      onPressed: this.onPressed,
    );
  }
}