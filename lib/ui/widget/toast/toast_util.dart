import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/animation/slide_in.dart';
import 'dart:async';

class ToastUtil {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;
  static Icon defaultIcon = Icon(Icons.thumb_up, size: 24);

  static void showCustomToast(
      BuildContext context,
      String message,
      {Icon icon})
  {
    if (toastTimer == null || !toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, message, icon == null? defaultIcon : icon);
      Overlay.of(context).insert(_overlayEntry);
      toastTimer = Timer(Duration(seconds: 2), () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }
  }

  static OverlayEntry createOverlayEntry(
      BuildContext context,
      String message,
      Icon icon)
  {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40.0,
        width: MediaQuery.of(context).size.width - 20,
        left: 10,
        child: SlideInAnimation(Material(
          elevation: 10.0,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                icon,
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
