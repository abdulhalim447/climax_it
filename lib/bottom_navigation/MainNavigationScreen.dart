import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';

import '../auth/saved_login/user_session.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/profile_setion/profle_screen.dart';
import '../screens/shoping/shoping_screen.dart';
import '../screens/show_reffer/show_reffer.dart';
import '../screens/wallet_section/wallet_screen/wallet_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomePage(),
      WalletScreen(),
      ShoppingScreen(),
      ReferralPage(),
      ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "হোম",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.black,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.wallet),
        title: "ওয়ালেট",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.blue.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.shopping_bag_rounded,
          color: Colors.white,
        ),
        title: "শপিং",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.blue.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.groups),
        title: "টিম",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.blue.shade200,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: "প্রোফাইল",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.blue.shade200,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineToSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        navBarStyle: NavBarStyle.style15,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : (screenWidth - 600) / 2,
        ),
      ),
    );
  }
}
