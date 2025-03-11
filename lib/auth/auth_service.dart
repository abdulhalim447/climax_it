import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../bottom_navigation/MainNavigationScreen.dart';
import 'base_url/api_config.dart';
import 'saved_login/user_session.dart';

class AuthService {
  static Future<void> login(BuildContext context, String phone, String password, String countryCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginApi),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password, 'countryCode': countryCode}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['message'] == 'Login successful!') {
          final userData = responseData['data'];
          String token = userData['token'];
          String name = userData['name'];
          String email = userData['email'];
          String referCode = userData['referCode'];
          String userID = userData['id'].toString();

          await UserSession.saveSession(token, phone, name, referCode, userID, email,'');

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          _showErrorDialog(context, responseData['message'] ?? 'Login failed');
        }
      } else {
        _showErrorDialog(context, 'Failed to login. Please try again.');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
