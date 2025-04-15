import 'dart:convert';

import 'package:climax_it_user_app/screens/wallet_section/wallet_screen/withdraw_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../auth/saved_login/user_session.dart';
import 'add_shopping_balance.dart';

class ShoppingBalance extends StatefulWidget {
  const ShoppingBalance({super.key});

  @override
  State<ShoppingBalance> createState() => _ShoppingBalanceState();
}

class _ShoppingBalanceState extends State<ShoppingBalance> {
  String shoppingWalletBalance = "৳00";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ইউজারের ID লোড করার ফাংশন
  Future<void> _loadUserId() async {
    final String? userID = await UserSession.getUserID();
    setState(() {
      userId = userID!;
    });

    if (userId.isNotEmpty) {
      _fetchWalletBalance(); // ইউজারের ব্যালেন্স চেক করবো
    }
  }

  // API থেকে ইউজারের ওয়ালেট ব্যালেন্স ফেচ করা
  Future<void> _fetchWalletBalance() async {
    try {
      var response = await http.post(
        Uri.parse(
            "https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "action": "check_balance",
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          shoppingWalletBalance = "৳${responseData['balance']}";
        });
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("ব্যালেন্স লোড করা সম্ভব হয়নি!");
    }
  }

  // মেসেজ দেখানোর ফাংশন
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      appBar: AppBar(
        title: Text('শপিং ব্যালেন্স'),
         // Darker yellow for app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for wallet section
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        size: 100, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      shoppingWalletBalance,
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text('বর্তমান শপিং ব্যালেন্স',
                        style: TextStyle(fontSize: 18, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShoppingBalance(shoppingWalletBalance: shoppingWalletBalance,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('শপিং ব্যালেন্স যোগ করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
