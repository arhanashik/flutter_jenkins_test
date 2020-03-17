import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/animation/slide_in.dart';
import 'dart:async';

class ToastUtil {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;

  static void show(
      BuildContext context,
      String message, {
        Icon icon = const Icon(Icons.thumb_up, size: 24, color: Colors.white,),
        bool fromTop = false,
        double verticalMargin = 40.0,
        bool error = false
  }) {
    if (toastTimer == null || !toastTimer.isActive) {
//      _overlayEntry = fromTop? _createOverlayEntryTop(
//          context, message, icon, verticalMargin: verticalMargin, error: error
//      ) : _createOverlayEntryBottom(
//          context, message, icon,  verticalMargin: verticalMargin, error: error
//      );
      _overlayEntry = _createOverlayEntryDirectional(
          context, 
          message, 
          icon, 
          fromTop: fromTop, 
          verticalMargin: verticalMargin,
          error: error
      );
      Overlay.of(context).insert(_overlayEntry);
      toastTimer = Timer(Duration(seconds: 2), () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }
  }

  static OverlayEntry _createOverlayEntryAnimated(
      BuildContext context,
      String message,
      Icon icon,{
        double verticalMargin = 40.0,
        bool error = false
  }) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: verticalMargin,
        width: MediaQuery.of(context).size.width - 20,
        left: 10,
        child: SlideInAnimation(Material(
          elevation: 10.0,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: error? Colors.redAccent : Colors.white,
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
                        color: error? Colors.white : Colors.black,
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

  static OverlayEntry _createOverlayEntryDirectional(
      BuildContext context,
      String message,
      Icon icon, {
        bool fromTop = false,
        double verticalMargin = 40.0,
        bool error = false
      }) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: fromTop? verticalMargin : null,
        bottom: fromTop? null : verticalMargin,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                    color: error? Colors.redAccent : Colors.blue,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    icon,
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
