import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../auth/saved_login/user_session.dart';
import 'income_screen.dart'; // নতুন স্ক্রীন ইমপোর্ট করা

class WalletScreen extends StatefulWidget {
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String balance = "৳00";


  @override
  void initState() {
    super.initState();
    fetchBalance();

  }



  Future<void> fetchBalance() async {
    String? userId = await UserSession.getUserID();
    if (userId == null) {
      print("Token is null. Cannot fetch data.");
      return;
    }

    print(userId);
    String apiUrl =
        "https://climaxitbd.com/php/income_filter/get_main_balance.php";


    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {"user_id": userId},
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data["status"] == "success") {
          setState(() {
            balance = "${data['balance']} BDT";
          });
        } else {
          setState(() {
            balance = balance;
            //balance = "Error: ${data['message']}";
          });
        }
      } else {
        setState(() {
          balance = "Server Error!";
        });
      }
    } catch (e) {
      setState(() {
        balance = "Failed to load balance!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('ওয়ালেট', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 60, color: Colors.blue),
                  SizedBox(height: 8.0),
                  Text(
                    'বর্তমান ব্যালেন্স',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    balance,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildCardItem(context, 'শপিং ব্যালেন্স দেখুন', ''),
                buildCardItem(context, 'আজকের ইনকাম', 'today'),
                buildCardItem(context, 'গতকালের ইনকাম', 'yesterday'),
                buildCardItem(context, '৭ দিনের ইনকাম', '7days'),
                buildCardItem(context, '৩০ দিনের ইনকাম', '30days'),
                buildCardItem(context, 'এখন পর্যন্ত মোট ইনকাম', 'all'),
                buildCardItem(context, 'মোট ইনকাম ইউথড্র', ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardItem(BuildContext context, String title, String filter) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncomeScreen(filter: filter, title: title),
            ),
          );
        },
        leading: Icon(Icons.folder, color: Colors.blue),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
