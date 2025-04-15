import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  String getProfileImageUrl(String? profilePic) {
    if (profilePic == null || profilePic.isEmpty) {
      return 'https://climaxitbd.com/php/profile/default_avatar.png'; // Replace with your default image
    }
    return 'https://climaxitbd.com/php/profile/$profilePic';
  }

  Future<void> fetchProfile() async {
    try {
      final String? userId = await UserSession.getUserID();
      if (userId == null || userId.isEmpty) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final response = await http.get(Uri.parse(
          'https://climaxitbd.com/php/auth/get_profile.php?user_id=$userId'));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData != null && decodedData is Map<String, dynamic>) {
          setState(() {
            profileData = decodedData;
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile. Please try again.')),
      );
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
              if (!hasError && profileData.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: profileData['name']?.toString() ?? '',
                      phone: profileData['phone']?.toString() ?? '',
                      email: profileData['email']?.toString() ?? '',
                      sex: profileData['sex']?.toString() ?? '',
                      address: profileData['address']?.toString() ?? '',
                      country: profileData['country']?.toString() ?? '',
                      profilePic: getProfileImageUrl(
                          profileData['profile_pic']?.toString()),
                    ),
                  ),
                ).then((_) => fetchProfile()); // Refresh profile after editing
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load profile data'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProfile,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : profileData.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          color: Colors.blue,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: NetworkImage(
                                  getProfileImageUrl(
                                      profileData['profile_pic']?.toString()),
                                ),
                                onBackgroundImageError: (e, s) {
                                  // Handle image load error
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profileData['name']?.toString() ?? 'N/A',
                                style: const TextStyle(
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
                                _buildInfoCard('সম্পূর্ণ নাম', 'name'),
                                _buildInfoCard('মোবাইল নাম্বার', 'phone'),
                                _buildInfoCard('ইমেইল', 'email'),
                                _buildInfoCard('লিঙ্গ', 'sex'),
                                _buildInfoCard('ঠিকানা', 'address'),
                                _buildInfoCard('দেশ', 'country'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: Text('No profile data available')),
    );
  }

  Widget _buildInfoCard(String title, String dataKey) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(profileData[dataKey]?.toString() ?? 'N/A'),
      ),
    );
  }
}
