import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefUtil {

  static const String SERIAL_NUMBER = "serial";
  static const String DEVICE_NAME = "device_name";
  static const String STORE_NAME = "store_name";
  static const String FCM_TOKEN = "fcm_token";
  static const String QR_SEARCH_HISTORY = "qr_search_history";
  static const String JAN_SEARCH_HISTORY = "jan_search_history";

  static save<T>(String key, value) async {
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