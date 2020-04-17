import 'package:flutter/material.dart';

class AppIcons {

  static AssetImage _loadImage(image) {
    return AssetImage(image,);
  }

  static ImageIcon _loadIcon(icon, {size = 24.0}) {
    return ImageIcon(_loadImage(icon), size: size,);
  }

  static ImageIcon loadIcon(icon, {size = 24.0, color = Colors.grey}) {
    if(icon is ImageIcon) {
      return ImageIcon(icon.image, size: size, color: color,);
    }

    return ImageIcon(_loadImage(icon), size: size, color: color,);
  }

  static ImageIcon loadSizedIcon(icon, {size = 24.0}) {
    if(icon is ImageIcon) {
      return ImageIcon(icon.image, size: size,);
    }

    return ImageIcon(_loadImage(icon), size: size,);
  }

  static const _iconDir = 'assets/icon/';
  static ImageIcon icList = _loadIcon('${_iconDir}ic_list.png',);
  static ImageIcon icClock = _loadIcon('${_iconDir}ic_clock.png',);
  static ImageIcon icBarCode = _loadIcon('${_iconDir}ic_bar_code.png',);
  static ImageIcon icQrCode = _loadIcon('${_iconDir}ic_qr_code.png',);
  static ImageIcon icArrowExport = _loadIcon('${_iconDir}ic_arrow_export.png',);
  static ImageIcon icArrowRight = _loadIcon('${_iconDir}ic_arrow_right.png',);
  static ImageIcon icBack = _loadIcon('${_iconDir}ic_back.png',);
  static ImageIcon icSettings = _loadIcon('${_iconDir}ic_settings.png',);
  static ImageIcon icBackToList = _loadIcon('${_iconDir}ic_back_to_list.png',);
  static ImageIcon icClose = _loadIcon('${_iconDir}ic_close.png',);
}