import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static Future<void> saveSession(String token, String phone, String name,
      String referCode,String userID,) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('phone', phone);
    prefs.setString('name', name);
    prefs.setString('referCode', referCode);
    prefs.setString('userID', userID);


  }



  static Future<String?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userID');
  }
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  static Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  static Future<String?> getReferCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('referCode');
  }

  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
