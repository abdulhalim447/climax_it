import 'dart:convert';
import 'package:climax_it_user_app/auth/SignupScreen.dart';
import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation/MainNavigationScreen.dart';
import 'base_url/api_config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  String countryCode = "+880"; // Default country code
  bool isLoading = false; // Flag for loading state

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> _login() async {
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog('Phone and password are required!');
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Combine country code and phone
      final String fullPhone = countryCode + phone;

      final response = await http.post(
        Uri.parse(ApiConfig.loginApi), // API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password, 'countryCode':countryCode}),
      );

      setState(() {
        isLoading = false; // End loading
      });

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['message'] == 'Login successful!') {
          final userData = responseData['data'];
          String token = userData['token'];
          String name = userData['name'];
          String referCode = userData['referCode'];
          String userID = userData['id'].toString();


          // Save data to UserSession
          //await UserSession.saveSession(token, fullPhone, name, referCode);
          // Save data to UserSession
          await UserSession.saveSession(token, fullPhone, name, referCode,userID);


          // Navigate to the next screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
                (Route<dynamic> route) => false, // Remove all routes
          );
        } else {
          _showErrorDialog(responseData['message'] ?? 'Login failed');
        }
      } else {
        _showErrorDialog('Failed to login. Please try again.');
      }
    } catch (error) {
      setState(() {
        isLoading = false; // End loading in case of error
      });
      _showErrorDialog('An error occurred.$error+ Please try again.');
    }
  }


  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center widget to center-align the content
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600
                  ? 400
                  : double.infinity, // Fixed width for larger screens
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Column(
                  children: [
                    Icon(
                      Icons.public,
                      size: 80,
                      color: Colors.blue,
                    ),
                    Text(
                      'Climax IT',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Micro Finance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.only(bottom: 1, top: 1),
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            countryCode = country.dialCode ?? "+880";
                          });
                        },
                        initialSelection: 'BD',
                        favorite: ['+880', 'BD'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                    ),
                    SizedBox(width: 2),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
