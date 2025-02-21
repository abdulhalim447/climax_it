import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final String? userId = await UserSession.getUserID();
    try {
      final response = await http.get(Uri.parse('https://climaxitbd.com/php/auth/get_profile.php?user_id=$userId'));

      if (response.statusCode == 200) {
        setState(() {
          profileData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit Profile functionality here
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Loading indicator
          : profileData.isNotEmpty
          ? Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(profileData['profile_pic'] ?? 'N/A'), // Add your image asset here
                ),
                const SizedBox(height: 8),
                Text(
                  profileData['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('সম্পূর্ণ নাম'),
                      subtitle: Text(profileData['name'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('মোবাইল নাম্বার'),
                      subtitle: Text(profileData['phone'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('ইমেইল'),
                      subtitle: Text(profileData['email'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('লিঙ্গ'),
                      subtitle: Text(profileData['sex'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('ঠিকানা'),
                      subtitle: Text(profileData['address'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('দেশ'),
                      subtitle: Text(profileData['country'] ?? 'N/A'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Center(child: Text('No profile data available')),  // Error handling for empty profileData
    );
  }
}
