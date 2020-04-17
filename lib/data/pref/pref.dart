import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefUtil {

  static const String IMEI = "imei";
  static const String DEVICE_NAME = "device_name";
  static const String STORE_NAME = "store_name";
  static const String FCM_TOKEN = "fcm_token";

  static save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  static read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    try{
      return json.decode(prefs.getString(key));
    } on Error catch(ex) {
      print(ex);
      return null;
    }
  }

  static remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

}