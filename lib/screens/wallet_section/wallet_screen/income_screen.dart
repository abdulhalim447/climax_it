import 'package:flutter/material.dart';

import '../../../auth/base_url/income_filter/income_filter_api.dart';
import '../../../auth/saved_login/user_session.dart';

class IncomeScreen extends StatefulWidget {
  final String filter;
  final String title;

  IncomeScreen({required this.filter, required this.title});

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUserID(); // Load userID when the screen is initialized
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
              child: Text(
                '${snapshot.data}৳', // Display the income
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
