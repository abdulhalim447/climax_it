import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../auth/saved_login/user_session.dart';
import '../../../widgets/web_view.dart';

class AddShoppingBalance extends StatefulWidget {
  const AddShoppingBalance({super.key, required this.shoppingWalletBalance});

  final String shoppingWalletBalance;

  @override
  State<AddShoppingBalance> createState() => _AddShoppingBalanceState();
}

class _AddShoppingBalanceState extends State<AddShoppingBalance> {
  final TextEditingController _amountController = TextEditingController();

  String userId = "";
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
   _userInfo();
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

        print("User ID: $userId, Email: $email, Name: $name");
      } else {
        print("User data is null");
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }





  @override
  void dispose() {
    _amountController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }


  ///for payment
  Future<void> createCheckout({
    required String fullName,
    required String email,
    required String amount,
    required String userId,
    required String orderId,
  }) async {
    const String baseURL = "https://pay.climaxitbd.com/";
    const String apiKey = "58c3af0decc37110a275a8ecabc4d68d6955fc80"; // API key

    final Uri url = Uri.parse("${baseURL}api/checkout-v2");

    final Map<String, dynamic> fields = {
      "full_name": fullName,
      "email": email,
      "amount": amount,
      "metadata": {"user_id": userId, "order_id": orderId},
      "redirect_url": "${baseURL}success.php",
      "return_type": "GET",
      "cancel_url": "${baseURL}cancel.php",
      "webhook_url":
      "https://pay.climaxitbd.com/callback/ae673c586c0a56ce5c10a304bd1c26e0cd87d120"
      // webhook ====
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

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Payment URL: ${data['payment_url']}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentWebView(
                paymentUrl: data['payment_url'],
              )),
        );
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('শপিং ব্যালেন্স যোগ করুন'),
        backgroundColor: Colors.blue, // AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 100, color: Colors.blue),
                        SizedBox(height: 10),
                        Text(
                          widget.shoppingWalletBalance,
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
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'টাকার পরিমাণ লিখুন',
                    hintText: 'যেমন: 100',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () async {
                    createCheckout(
                        fullName: name!,
                        email: email!,
                        amount: _amountController.text,
                        userId: userId!,
                        orderId: '');
                  },
                  child: Text('পেমেন্ট করুন', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.blue, // Button color
                    shadowColor: Colors.blueAccent, // Shadow color
                    elevation: 5, // Elevation for shadow
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
