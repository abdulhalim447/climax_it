import 'dart:convert';
import 'package:http/http.dart' as http;
import '../saved_login/user_session.dart';

class VerificationService {
  bool isVerified = false;
  String userId = "";
  String name = "";
  String email = "";

  // Add the initialize method
  Future<void> initialize() async {
    await _userInfo();
    if (userId.isNotEmpty) {
      await _checkUserVerification();
    }
  }

  Future<void> _userInfo() async {
    try {
      String? fetchedUserId = await UserSession.getUserID();
      String? fetchedEmail = await UserSession.getEmail();
      String? fetchedName = await UserSession.getName();

      if (fetchedUserId != null && fetchedEmail != null && fetchedName != null) {
        userId = fetchedUserId;
        email = fetchedEmail;
        name = fetchedName;
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _checkUserVerification() async {
    try {
      final response = await http.get(Uri.parse(
          "https://climaxitbd.com/php/wallet/check_user_verify.php?user_id=$userId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("isVarified")) {
          int verificationStatus = int.tryParse(data["isVarified"].toString()) ?? 0;
          isVerified = verificationStatus == 1;
        }
      } else {
        isVerified = false;
      }
    } catch (e) {
      print("Error checking verification: $e");
      isVerified = false;
    }
  }
}
