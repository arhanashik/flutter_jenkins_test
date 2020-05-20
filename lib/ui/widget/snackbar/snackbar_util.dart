import 'package:flutter/material.dart';
import 'package:o2o/ui/widget/animation/slide_in.dart';
import 'dart:async';

import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';

class SnackbarUtil {
  static Timer _snackbarTimer;
  static OverlayEntry _overlayEntry;

  static void show(
      BuildContext context,
      String message,
      {
        Widget icon,
        Color textColor: Colors.white,
        FontWeight fontWeight: FontWeight.bold,
        Color background: AppColors.colorBlueDark,
        int durationInSec: 4
      }
  ) {
    if (_snackbarTimer == null || !_snackbarTimer.isActive) {
      _overlayEntry = _createOverlayEntry(
          context, message, icon, textColor, fontWeight, background, durationInSec*1000
      );
      Overlay.of(context).insert(_overlayEntry);
      _snackbarTimer = Timer(Duration(seconds: durationInSec), () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }
  }

  static _snackbarView(
      String message,
      Widget icon,
      Color textColor,
      FontWeight fontWeight,
      Color background,
  ) {
    final snackIcon = icon == null? AppIcons.loadIcon(
        AppIcons.icLike, color: Colors.white
    ) : icon;
    return Material(
      elevation: 10.0,
      child: Container(
        color: background,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            snackIcon,
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static OverlayEntry _createOverlayEntry(
      BuildContext context,
      String message,
      Widget icon,
      Color textColor,
      FontWeight fontWeight,
      Color background,
      int durationInMills,
  ) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0.0,
        width: MediaQuery.of(context).size.width,
        child: SlideInAnimation(
            _snackbarView(message, icon, textColor, fontWeight, background),
          durationInMills: durationInMills,
        ),
      ),
    );
  }
}
