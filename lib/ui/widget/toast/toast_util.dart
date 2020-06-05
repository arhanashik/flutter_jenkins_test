import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/animation/slide_in.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'dart:async';

import 'package:o2o/ui/widget/common/app_icons.dart';

class ToastUtil {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;

  static show(
      BuildContext context,
      String message, {
        Widget icon,
        bool fromTop = false,
        double verticalMargin = 40.0,
        bool error = false,
        duration = const Duration(seconds: 3),
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
      toastTimer = Timer(duration, () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }
  }

  static clear() {
    if(_overlayEntry != null && toastTimer.isActive) {
      _overlayEntry.remove();
      toastTimer.cancel();
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

  static _toastView(
      String message,
      Widget icon,
      bool error,
      ) {
    final toastIcon = icon == null? AppIcons.loadIcon(
        AppIcons.icLike, color: Colors.white, size: 16.0
    ) : icon;
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
            color: error? AppColors.colorAccent : AppColors.colorBlue,
            borderRadius: BorderRadius.circular(3)
        ),
        child: Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              toastIcon,
              Flexible (
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    message,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static OverlayEntry _createOverlayEntryDirectional(
      BuildContext context,
      String message,
      Widget icon, {
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
            Flexible(child: _toastView(message, icon, error),)
          ],
        ),
      ),
    );
  }
}

