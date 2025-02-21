import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../saved_login/user_session.dart';

class WalletService {
  // Function to fetch wallet data
  static Future<void> fetchWalletBalance() async {
    try {
      // Retrieve the token from UserSession
      String? token = await UserSession.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      // Define API URL
      final String apiUrl = "https://climaxitbd.com/php/wallet/get_wallet_balance.php?token=$token";

      // Make the GET request
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse JSON response
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Extract wallet data
          final walletData = data['data'];
          final String name = walletData['name'];
          final String mainWalletBalance = walletData['main_wallet_balance'];
          final String shoppingWalletBalance = walletData['shopping_wallet_balance'];

          // Save data to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name);
          await prefs.setString('main_wallet_balance', mainWalletBalance);
          await prefs.setString('shopping_wallet_balance', shoppingWalletBalance);

          print("Wallet data saved successfully.");
        } else {
          throw Exception("Failed to fetch wallet data: ${data['status']}");
        }
      } else {
        throw Exception("Failed to connect to the API");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
