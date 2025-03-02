import 'dart:convert';

import 'package:climax_it_user_app/screens/app_download/app_download.dart';
import 'package:climax_it_user_app/screens/micro_job/show_job_grid.dart';
import 'package:climax_it_user_app/screens/wallet_section/wallet_screen/withdraw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../auth/saved_login/user_session.dart';
import '../../slider/home_screen_slider.dart';
import '../../widgets/web_view.dart';
import '../course/course_list_page.dart';
import '../digital_service/digital_service.dart';
import '../drive_offer/drive_offer.dart';
import '../my_work_screen/my_work_screen.dart';
import '../shoping/shoping_screen.dart';
import 'package:climax_it_user_app/auth/LoginScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isVerified = false;
  String userId = "";
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _userInfo().then((_) {
      if (userId.isNotEmpty) {
        _checkUserVerification(); // Only check verification after userId is set
      }
    });
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

  Future<void> _checkUserVerification() async {
    try {
      final response = await http.get(Uri.parse(
          "https://climaxitbd.com/php/wallet/check_user_verify.php?user_id=$userId"));

      print("Verification Response Status: ${response.statusCode}");
      print("Verification Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Make sure we're checking the exact value and type
        setState(() {
          // Convert to int first to ensure proper comparison
          int verificationStatus = data["isVarified"] is String
              ? int.parse(data["isVarified"])
              : data["isVarified"];
          isVerified = verificationStatus == 1;
        });

        print("Verification Status: $isVerified");
      } else {
        print("Failed to fetch verification status: ${response.statusCode}");
        setState(() {
          isVerified = false; // Default to false on error
        });
      }
    } catch (e) {
      print("Error checking verification: $e");
      setState(() {
        isVerified = false; // Default to false on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      // ড্রয়ার
      drawer: _buildDrawer(context),

      // main body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeBannerSlider(),
            _idVerificationSection(),
            // সার্ভিস সমূহ
            _buildSectionTitle('সার্ভিস সমূহ'),
            _buildServiceGrid(context),
            // আসন্ন ফিচার সমূহ
            _buildSectionTitle('আসন্ন ফিচার-সমূহ'),
            _buildUpcomingFeatureGrid(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Climax IT'),
      automaticallyImplyLeading: true,
      centerTitle: true,

      // ডানপাশে আইকনগুলো
      actions: [
        // নোটিফিকেশন আইকন
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // এখানে আপনার নোটিফিকেশন সম্পর্কিত কোড যোগ করুন
            print('Notification icon pressed!');
          },
        ),

        // কাস্টমার সার্ভিস আইকন
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // এখানে ফোন কল করার লজিক যুক্ত করুন
            print('Customer service icon pressed!');
          },
        ),
      ],
    );
  }

  // navigation  drawer section ===================
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: FutureBuilder(
              future: Future.wait([
                UserSession.getName(),
                UserSession.getReferCode(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error fetching data',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final data = snapshot.data as List<String?>;
                  final name = data[0] ?? "No Name";
                  final referCode = data[1] ?? "No Refer Code";

                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'রেফার কোড: $referCode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: referCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('রেফার কোড কপি হয়েছে!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.video_camera_front_outlined),
            title: const Text(' আমার ক্লাস'),
            onTap: () {
              if (isVerified) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoListScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("আপনার একাউন্টটি ভেরিফাই করুন!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('অর্ডার হিস্টোরি'),
            onTap: () {
              if (isVerified) {
                Navigator.pop(context);
                print('Order History clicked!');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("আপনার একাউন্টটি ভেরিফাই করুন!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('উইথড্র'),
            onTap: () {
              if (isVerified) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WithdrawScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("আপনার একাউন্টটি ভেরিফাই করুন!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          const Divider(),
          // support section ==========================
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "সাপোর্ট",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, // বোল্ড টেক্সট
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('কল'),
            onTap: () {
              _launchURL('tel:+8801928374259');
            },
          ),
          ListTile(
            leading: const Icon(Icons.facebook),
            title: const Text('ফেইসবুক'),
            onTap: () {
              _launchURL('https://www.facebook.com/climaxitbdofficial');
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('ইউটিউব'),
            onTap: () {
              _launchURL('https://www.youtube.com/@ClimaxITBD');
            },
          ),
          ListTile(
            leading: const Icon(Icons.telegram),
            title: const Text('টেলিগ্রাম'),
            onTap: () {
              _launchURL('https://t.me/climaxitbd');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('ইন্সট্রাগ্রাম'),
            onTap: () {
              _launchURL('');
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_in_map_outlined),
            title: const Text('এক্স'),
            onTap: () {
              _launchURL('https://x.com/climaxitbd');
            },
          ),

          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('টিকটক'),
            onTap: () {
              _launchURL('https://www.tiktok.com/@climaxit');
            },
          ),

          const Divider(),
          // support section ==========================
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "অন্যান্য",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, // বোল্ড টেক্সট
              ),
            ),
          ),

          /* ListTile(
            leading: const Icon(Icons.language),
            title: const Text('ভাষা পরিবর্তন'),
            onTap: () {
              Navigator.pop(context);
              print('TikTok clicked!');
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('টার্মস এন্ড কন্ডিশন'),
            onTap: () {
              Navigator.pop(context);
              print('TikTok clicked!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_sharp),
            title: const Text('প্রাইভেসি পলিসি'),
            onTap: () {
              Navigator.pop(context);
              print('TikTok clicked!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('ডাটা ডিলিট পলিসি'),
            onTap: () {
              Navigator.pop(context);
              print('TikTok clicked!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('লগআউট'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout Confirmation'),
                    content: const Text('Do you really want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logout(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

//=================================================================================================
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

//=============================================================================
  Widget _idVerificationSection() {
    // If verified, return an empty container (invisible)
    if (isVerified) {
      return const SizedBox.shrink();
    }

    // Show verification section only if not verified
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'আপনার একাউন্টটি ভেরিফাই করুন!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'আমাদের সকল সার্ভিস ব্যবহার করতে আপনার একাউন্টটি ভেরিফাই করুন। ধন্যবাদ।',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                createCheckout(
                    fullName: name!,
                    email: email!,
                    amount: '10',
                    userId: userId!,
                    orderId: '');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'ভেরিফাই করুন',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    // উদাহরণস্বরূপ কিছু সার্ভিস আইটেম
    final List<Map<String, String>> services = [
      {"icon": "assets/icons/amar_kaj.png", "label": "আমার কাজ"},
      {"icon": "assets/icons/img.png", "label": "ড্রাইভ অফার"},
      {"icon": "assets/icons/img_1.png", "label": "মাক্রো জব"},
      {"icon": "assets/icons/img_2.png", "label": "স্কিল অর্জন"},
      {"icon": "assets/icons/img_3.png", "label": "রিসেলিং"},
      {"icon": "assets/icons/img_4.png", "label": "ডিজিটাল সার্ভিস"},
      {"icon": "assets/icons/img_5.png", "label": "প্রিমিয়াম অ্যাপ"},
    ];

    // আলাদা স্ক্রিনের লিস্ট
    final List<Widget> screens = [
      MyWorkScreen(),
      DriveOfferScreen(),
      ShowJobGrid(),
      VideoListScreen(),
      ShoppingScreen(),
      DigitalServiceScreen(),
      AppGridScreen()
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = services[index];
          return GestureDetector(
            onTap: isVerified
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screens[index]),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("আপনার একাউন্টটি ভেরিফাই করুন!"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isVerified ? Colors.blue : Colors.grey,
                  child: Image.asset(
                    item["icon"] ?? "",
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["label"] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingFeatureGrid() {
    // উদাহরণস্বরূপ কিছু আসন্ন ফিচার আইটেম
    final List<Map<String, String>> upcomingFeatures = [
      {"icon": "⬇️", "label": "মোবাইল রিচার্জ"},
      {"icon": "📰", "label": "আর্টিকেল পড়ে ইনকাম"},
      {"icon": "❓", "label": "কুইজ খেলে ইনকাম"},
      {"icon": "🎬", "label": "ভিডিও দেখে ইনকাম"},
      {"icon": "➕", "label": "অংক করে ইনকাম"},
      {"icon": "💵", "label": "মাসিক বেতন"},
      {"icon": "🎲", "label": "গেমস খেলে ইনকাম"},
      {"icon": "📋", "label": "ফর্ম তৈরি"},
      {"icon": "⌨️", "label": "টাইপিং জব"},
      {"icon": "💻", "label": "ফ্রি ফ্রিল্যান্সিং কোর্স"},
      {"icon": "🛍️", "label": "ফ্রি ইকমার্স ওয়েব সাইট"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingFeatures.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = upcomingFeatures[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isVerified ? Colors.blue : Colors.grey,
                child: Text(
                  item["icon"] ?? "",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item["label"] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

// Slider Scetion

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

void _logout(BuildContext context) async {
  await UserSession.clearSession();

  // Navigate to the login screen and remove all previous screens from stack
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (Route<dynamic> route) => false,
  );
}
