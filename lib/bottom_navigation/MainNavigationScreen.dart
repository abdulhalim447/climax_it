import 'package:climax_it_user_app/auth/base_url/wallet_balances/save_wallet_balances.dart';
import 'package:flutter/material.dart';

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
