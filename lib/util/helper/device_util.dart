import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

/// Created by mdhasnain
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Provides function which depend on the platform(Android/iOS)
/// 2.
/// 3.
class DeviceUtil {
  ///Provides the unique device identifier
  static Future<String> getSerialNumber() async {
    String os = Platform.operatingSystem; //in your code
    print(os);

    String identifier = "";
    if (Platform.isAndroid) {
      identifier = await UniqueIdentifier.serial;
    } else if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      var data = await deviceInfoPlugin.iosInfo;
      identifier = data.identifierForVendor;
    }

    print("imei: " + identifier);

    return identifier;
  }

  ///This function calls device's default phone calling app
  static makePhoneCall(String phoneNumber) async {
    await UrlLauncher.launch('tel:$phoneNumber');
  }

  ///This function calls device's default messaging app
  static sendMessage(String phoneNumber, String message) async {
    await UrlLauncher.launch('sms:$phoneNumber');
  }

  ///This function calls device's default mailing app
  static sendMail(String email, String subject, String body) async {
    await UrlLauncher.launch('mailto:$email?subject=$subject&body=$body');
  }

  ///This function calls device's default web browser
  static openUrl(String url) async {
    await UrlLauncher.launch(url);
  }
}