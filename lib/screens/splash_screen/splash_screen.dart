import 'package:climax_it_user_app/auth/LoginScreen.dart';
import 'package:climax_it_user_app/bottom_navigation/MainNavigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:climax_it_user_app/auth/saved_login/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    String? token = await UserSession.getToken(); // Get token from SharedPreferences

    if (token != null && token.isNotEmpty) {
      // If token exists, navigate to MainNavigationScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } else {
      // If no token, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              Spacer(),
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
