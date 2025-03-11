import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/saved_login/user_session.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/profile_setion/profle_screen.dart';
import '../screens/shoping/shoping_screen.dart';
import '../screens/show_reffer/show_reffer.dart';
import '../screens/wallet_section/wallet_screen/wallet_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool isVerified = false;
  String userId = "";
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _userInfo().then((_) {
      if (userId.isNotEmpty) {
        _checkUserVerification(); // Only check verification after userId is set
      }
    });
  }

  Future<void> _userInfo() async {
    try {
      String? fetchedUserId = await UserSession.getUserID();
      String? fetchedEmail = await UserSession.getEmail();
      String? fetchedName = await UserSession.getName();

      // Null চেক করে UI আপডেট করো
      if (fetchedUserId != null &&
          fetchedEmail != null &&
          fetchedName != null) {
        setState(() {
          userId = fetchedUserId;
          email = fetchedEmail;
          name = fetchedName;
        });

      } else {
       // print("User data is null");
      }
    } catch (e) {
      //print("Error fetching user info: $e");
    }
  }

  Future<void> _checkUserVerification() async {
    try {
      final response = await http.get(Uri.parse(
          "https://climaxitbd.com/php/wallet/check_user_verify.php?user_id=$userId"));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Make sure we're checking the exact value and type
        setState(() {
          // Convert to int first to ensure proper comparison
          int verificationStatus = data["isVarified"] is String
              ? int.parse(data["isVarified"])
              : data["isVarified"];
          isVerified = verificationStatus == 1;
        });

        print("Verification Status: $isVerified");
      } else {
        setState(() {
          isVerified = false; // Default to false on error
        });
      }
    } catch (e) {
      setState(() {
        isVerified = false; // Default to false on error
      });
    }
  }

  // List of screens for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomePage(),
    WalletScreen(),
    ShoppingScreen(),
    ReferralPage(),
    ProfilePage(),

/*    CardScreen(),
    ContactScreen(),
    ProfileScreen(),*/
  ];

  void _onItemTapped(int index) {
    if (index == 1 || index == 2 || index == 3 || index == 4) {
      // Wallet, Shopping, Profile
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("আপনার একাউন্টটি ভেরিফাই করুন!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return; // Prevent navigation if not verified
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    print("Screen width: $screenWidth"); // স্ক্রিন প্রস্থ দেখুন
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : (screenWidth - 600) / 2),
        child: Container(
          width: isMobile ? double.infinity : 600,
          child: BottomNavigationBar(
            backgroundColor: Colors.blue,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'হোম',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'ওয়ালেট',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: 'শপিং',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'টিম',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'প্রোফাইল',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
