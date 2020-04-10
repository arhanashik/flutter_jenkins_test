import 'package:flutter/material.dart';

class AppImages {

  static Image loadImage(String imageUrl, {isAsset = true, placeholder = NO_IMAGE_URL}) {
    return isAsset? Image.asset(imageUrl.isEmpty? placeholder : imageUrl, fit: BoxFit.fill,)
        : Image.network(
      imageUrl.isEmpty || !imageUrl.startsWith("http")
          ? placeholder : imageUrl, fit: BoxFit.fill,
    );
  }

  static Image loadSizedImage(
      String imageUrl,
      {width = 24.0, height = 24.0, isAsset = true, placeholder = NO_IMAGE_URL}) {
    if(isAsset) {
      return Image.asset(
        imageUrl, fit: BoxFit.fill, width: width, height: height,
      );
    }

    return Image.network(
      imageUrl.isEmpty || !imageUrl.startsWith("http")? placeholder : imageUrl,
      fit: BoxFit.fill,
      width: width,
      height: height,
    );
  }

  static const NO_IMAGE_URL = 'https://via.placeholder.com/150/999999/fff?text=NO+IMAGE';
  static const NO_IMAGE_URL_LARGE = 'https://via.placeholder.com/240/999999/fff?text=NO+IMAGE';

  static const _imageDir = 'assets/images/';
  static const icDigit1Url = '${_imageDir}ic_digit_1.png';
  static const icDigit2Url = '${_imageDir}ic_digit_2.png';
  static const icDigit2RedUrl = '${_imageDir}ic_digit_2_red.png';
  static const icDigit3Url = '${_imageDir}ic_digit_3.png';
  static const icDigit3RedUrl = '${_imageDir}ic_digit_3_red.png';

  static Image imgLabelInstruction = loadImage('${_imageDir}img_label_instruction.png');
  static Image imgTagInstruction = loadImage('${_imageDir}img_tag_instruction.png');
  static Image imgQrCodeLabelOk = loadImage('${_imageDir}img_qr_code_label_ok.png');
  static Image imgQrCodeLabelErrorStep2 = loadImage('${_imageDir}img_qr_code_label_error_step_2.png');
  static Image imgQrCodeLabelErrorStep3 = loadImage('${_imageDir}img_qr_code_label_error_step_3.png');
  static Image icDigit1 = loadSizedImage(icDigit1Url);
  static Image icDigit2 = loadSizedImage(icDigit2Url);
  static Image icDigit2Red = loadSizedImage(icDigit2RedUrl);
  static Image icDigit3 = loadSizedImage(icDigit3Url);
  static Image icDigit3Red = loadSizedImage(icDigit3RedUrl);
}