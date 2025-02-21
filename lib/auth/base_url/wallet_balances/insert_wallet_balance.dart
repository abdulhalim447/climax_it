import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../saved_login/user_session.dart';

class InsertWalletBalance {
  // Function to insert wallet balance
  static Future<bool> insertWalletBalance({
    required String? mainWalletBalance,
    required String? shoppingWalletBalance,
  }) async {
    try {
      // Retrieve the token from UserSession
      String? token = await UserSession.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      // API URL
      final String apiUrl = "https://climaxitbd.com/php/wallet/insert_wallet_balance.php";

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "token": token,
        "main_wallet_balance": mainWalletBalance ?? "",
        "shopping_wallet_balance": shoppingWalletBalance ?? "",
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      // Check the response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          print("Wallet balance inserted successfully.");
          return true;
        } else {
          print("Failed to insert wallet balance: ${responseData['message']}");
          return false;
        }
      } else {
        throw Exception("Failed to connect to the API. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in insertWalletBalance: $e");
      return false;
    }
  }
}
