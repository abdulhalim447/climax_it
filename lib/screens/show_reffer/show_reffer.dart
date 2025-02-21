import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReferralPage extends StatefulWidget {
  @override
  _ReferralPageState createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  late Future<Map<String, dynamic>> referralData;

  @override
  void initState() {
    super.initState();
    referralData = fetchReferralData();
  }

  // API থেকে ডাটা ফেচ করার ফাংশন
  Future<Map<String, dynamic>> fetchReferralData() async {
    String? userID = await UserSession.getUserID();
    final response = await http.get(Uri.parse(
        'https://climaxitbd.com/php/auth/get-referral-list.php?userId=$userID'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load referral data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referral Levels'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: referralData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            // যদি level1 খালি থাকে, তখন "No referrals found" দেখান
            if (data['level1'].isEmpty) {
              return Center(child: Text('আপনার কোনো রেফার খুঁজে পাওয়া যায়নি।'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('প্রথম লেভেল',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(data['level1'].length, (index) {
                    final level = data['level1'][index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('নাম: ${level['name']}',
                                    style: TextStyle(fontSize: 18)),
                                Text('ইউজার নাম: ${level['username']}',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  Text('২য় লেভেল = ${data['level2']}',
                      style: TextStyle(fontSize: 18)),
                  Text('৩য় লেভেল = ${data['level3']}',
                      style: TextStyle(fontSize: 18)),
                  Text('৪র্থ লেভেল = ${data['level4']}',
                      style: TextStyle(fontSize: 18)),
                  Text('৫ম লেভেল = ${data['level5']}',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('আপনার কোনো রেফার খুঁজে পাওয়া যায়নি',
                  style: TextStyle(fontSize: 18)),
            ));
          }
        },
      ),
    );
  }
}
