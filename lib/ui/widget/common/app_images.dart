import 'package:flutter/material.dart';

class AppImages {

  static Image loadImage(imageUrl, {isAsset = true, placeholder = NO_IMAGE_URL}) {
    return isAsset? Image.asset(imageUrl, fit: BoxFit.fill,)
        : Image.network(
      imageUrl.isEmpty? placeholder : imageUrl, fit: BoxFit.fill,
    );
  }

  static Image loadSizedImage(
      imageUrl,
      {width = 24.0, height = 24.0, isAsset = true, placeholder = NO_IMAGE_URL}) {
    if(isAsset) {
      return Image.asset(
        imageUrl, fit: BoxFit.fill, width: width, height: height,
      );
    }

    return Image.network(
      imageUrl.isEmpty? placeholder : imageUrl,
      fit: BoxFit.fill,
      width: width,
      height: height,
    );
  }

  static const NO_IMAGE_URL = 'https://via.placeholder.com/150/999999/fff?text=NO+IMAGE';
  static const NO_IMAGE_URL_LARGE = 'https://via.placeholder.com/240/999999/fff?text=NO+IMAGE';

  static const _imageDir = 'assets/images/';
  static Image imgLabelInstruction = loadImage('${_imageDir}img_label_instruction.png');
  static Image imgTagInstruction = loadImage('${_imageDir}img_tag_instruction.png');
  static Image imgQrCodeLabelOk = loadImage('${_imageDir}img_qr_code_label_ok.png');
  static Image imgQrCodeLabelErrorStep2 = loadImage('${_imageDir}img_qr_code_label_error_step_2.png');
  static Image imgQrCodeLabelErrorStep3 = loadImage('${_imageDir}img_qr_code_label_error_step_3.png');
}