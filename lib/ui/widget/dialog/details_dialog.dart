import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/util/common.dart';

class DetailsDialog {
  final BuildContext context;
  final String title;
  final String subtitle;
  final String imgUrl;

  DetailsDialog(this.context, this.title, this.subtitle, this.imgUrl);

  show() {
    final imageUrl = imgUrl.isEmpty ? AppConst.NO_IMAGE_URL_LARGE : imgUrl;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: Common.roundRectBorder(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      imageUrl,
                      width: MediaQuery.of(context).size.width - 120,
                      height: MediaQuery.of(context).size.width - 120,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 32,),
                  child: Text(
                    subtitle,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
