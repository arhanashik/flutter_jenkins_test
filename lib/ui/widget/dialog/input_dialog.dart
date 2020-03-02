import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/util/common.dart';

class InputDialog {
  final BuildContext context;
  final String title;
  final String btnTxt;
  final Function onTxtChange;
  final Function onBtnTap;

  String insertedCode = '';

  InputDialog(this.context, this.title, this.btnTxt, this.onBtnTap, {this.onTxtChange});

  show() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: Common.roundRectBorder(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    Spacer(),
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    autofocus: true,
                    onChanged: (text) {
                      insertedCode = text;
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
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 10),)
              ],
            ),
          );
        });
  }
}