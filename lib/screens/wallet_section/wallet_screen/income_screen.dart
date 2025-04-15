import 'package:flutter/material.dart';

import '../../../auth/base_url/income_filter/income_filter_api.dart';
import '../../../auth/saved_login/user_session.dart';

class IncomeScreen extends StatefulWidget {
  final String filter;
  final String title;

  const IncomeScreen({super.key, required this.filter, required this.title});

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUserID();
  }

  // Function to load the userID from UserSession
  _loadUserID() async {
    String? userIdFromSession = await UserSession.getUserID();
    setState(() {
      userID = userIdFromSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If userID is null, show a loading indicator until it's loaded
    if (userID == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<double>(
        future: fetchIncome(userID!, widget.filter), // Pass the userID here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Center(

              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 300,
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
                          '${snapshot.data}৳',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      SizedBox(height: 10),
                      Text(widget.title,
                          style: TextStyle(fontSize: 18, color: Colors.blue)),
                    ],
                  ),
                ),
              ),


            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
