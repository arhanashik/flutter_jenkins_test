import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefUtil {

  static const String IMEI = "imei";
  static const String DEVICE_NAME = "device_name";
  static const String STORE_NAME = "store_name";

  static save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  static read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key));
  }

  static remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

}