import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class DeviceUtil {
  static Future<String> getIMEI() async {
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

  static makePhoneCall(String phoneNumber) async {
    await UrlLauncher.launch('tel:$phoneNumber');
  }

  static sendMessage(String phoneNumber, String message) async {
    await UrlLauncher.launch('sms:$phoneNumber');
  }

  static sendMail(String email, String subject, String body) async {
    await UrlLauncher.launch('mailto:$email?subject=$subject&body=$body');
  }

  static openUrl(String url) async {
    await UrlLauncher.launch(url);
  }
}