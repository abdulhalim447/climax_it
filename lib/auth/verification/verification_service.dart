import 'dart:convert';
import 'package:http/http.dart' as http;
import '../saved_login/user_session.dart';

class VerificationService {
  // Base URL for API calls
  static const String _baseUrl = "https://climaxitbd.com/php";

  // Check user verification status
  Future<bool> checkVerification() async {
    try {
      String? userId = await UserSession.getUserID();

      if (userId == null || userId.isEmpty) {
        return false;
      }

      final response = await http.get(
          Uri.parse("$_baseUrl/wallet/check_user_verify.php?user_id=$userId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("isVarified")) {
          int verificationStatus =
              int.tryParse(data["isVarified"].toString()) ?? 0;
          return verificationStatus == 1;
        }
      }

      return false;
    } catch (e) {
      print("Error checking verification: $e");
      return false;
    }
  }

  // Initiate verification process with payment
  Future<String?> initiateVerification(
      String fullName, String email, String amount, String userId) async {
    const String baseURL = "https://pay.climaxitbd.com/";
    const String apiKey = "58c3af0decc37110a275a8ecabc4d68d6955fc80";

    final Uri url = Uri.parse("${baseURL}api/checkout-v2");

    final Map<String, dynamic> fields = {
      "full_name": fullName,
      "email": email,
      "amount": amount,
      "metadata": {"user_id": userId, "order_id": "verification"},
      "redirect_url": "${baseURL}success.php",
      "return_type": "GET",
      "cancel_url": "${baseURL}cancel.php",
      "webhook_url":
          "https://pay.climaxitbd.com/callback/ae673c586c0a56ce5c10a304bd1c26e0cd87d120"
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "RT-UDDOKTAPAY-API-KEY": apiKey,
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(fields),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_url'];
      } else {
        print("Error initiating verification: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception during verification: $e");
      return null;
    }
  }

  // Update user verification status (e.g., after successful payment)
  Future<bool> updateVerificationStatus(String userId,
      {bool verified = true}) async {
    try {
      final url = Uri.parse('$_baseUrl/wallet/verify_pay.php');

      Map<String, dynamic> data = {
        'user_id': userId,
        'shopping_wallet_balance': "0",
        'isVarified': verified ? "1" : "0",
      };

      final response = await http.post(url, body: json.encode(data), headers: {
        'Content-Type': 'application/json',
      });

      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error updating verification status: $e");
      return false;
    }
  }
}
