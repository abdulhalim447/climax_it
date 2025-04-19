import 'dart:convert';
import 'package:climax_it_user_app/main.dart';
import 'package:climax_it_user_app/screens/app_download/app_download.dart';
import 'package:climax_it_user_app/screens/micro_job/show_job_grid.dart';
import 'package:climax_it_user_app/screens/order_history/order_history.dart';
import 'package:climax_it_user_app/screens/support/live_support.dart';
import 'package:climax_it_user_app/screens/wallet_section/wallet_screen/withdraw_screen.dart';
import 'package:climax_it_user_app/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/saved_login/user_session.dart';
import '../../slider/home_screen_slider.dart';
import '../../widgets/web_view.dart';
import '../course/course_list_page.dart';
import '../digital_service/digital_service.dart';
import '../donation/donation.dart';
import '../drive_offer/drive_offer.dart';
import '../my_work_screen/my_work_screen.dart';
import '../notification/notification_screen.dart';
import '../shoping/shoping_screen.dart';
import 'package:climax_it_user_app/auth/LoginScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

String userId = "";
String name = "";
String email = "";

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    _userInfo();
    _showWelcomeDialog(); // Show welcome dialog if applicable
    _showFacebookGroupDialog();
  }

  Future<void> _userInfo() async {
    try {
      String? fetchedUserId = await UserSession.getUserID();
      String? fetchedEmail = await UserSession.getEmail();
      String? fetchedName = await UserSession.getName();

      if (fetchedUserId != null &&
          fetchedEmail != null &&
          fetchedName != null) {
        userId = fetchedUserId;
        email = fetchedEmail;
        name = fetchedName;
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _showWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString('last_welcome_dialog_date');
    final today = DateTime.now()
        .toIso8601String()
        .split('T')[0]; // Get current date in YYYY-MM-DD format

    if (lastShownDate != today) {
      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('😊 স্বাগতম!'),
            content: Text('আপনাকে পেয়ে আমরা আনন্দিত। উপভোগ করুন! ধন্যবাদ। '),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Update the last shown date
      await prefs.setString('last_welcome_dialog_date', today);
    }
  }

  Future<void> _showFacebookGroupDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenDialog =
        prefs.getBool('has_seen_facebook_group_dialog') ?? false;

    if (!hasSeenDialog) {
      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('👥আমাদের ফেসবুক গ্রুপে যোগ দিন!'),
            content: Text(
                'আমাদের ফেসবুক গ্রুপে যোগদান করে আপডেট থাকুন এবং অন্যদের সাথে সংযুক্ত থাকুন।.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('না'),
              ),
              TextButton(
                onPressed: () {
                  _launchURL(
                      'https://www.facebook.com/climaxitbdofficial'); // Replace with your Facebook group link
                  Navigator.of(context).pop();
                },
                child: Text('যোগ দিন'),
              ),
            ],
          );
        },
      );

      // Update the preference to indicate the dialog has been shown
      await prefs.setBool('has_seen_facebook_group_dialog', true);
    }
  }

// Main section of the screen================================================

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
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: HomeBannerSlider(),
            ),
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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LiveSupport()));
        },
        tooltip: 'Increament',
        child: const Icon(
          Icons.support_agent,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  //=======================================================================

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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationScreen()));
          },
        ),

        // কাস্টমার সার্ভিস আইকন
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // এখানে ফোন কল করার লজিক যুক্ত করুন
            _launchURL('tel:09647374259');
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
                UserSession.getProfilePic(),
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
                  final profilepic = data[2] ?? "No Refer Code";

                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://climaxitbd.com/php/profile/$profilepic',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          name + (verificationService.isVerified ? ' *️⃣' : ''),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
                                    fontSize: 10,
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoListScreen()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('অর্ডার হিস্টোরি'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderHistory()));
              print('Order History clicked!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('উইথড্র'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WithdrawScreen()));
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
            leading: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                );
              },
            ),
            title: const Text('ডার্ক মোড'),
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            onTap: () {
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
          ),
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
    if (verificationService.isVerified) {
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
                    fullName: name,
                    email: email,
                    amount: '500',
                    userId: userId,
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
      {"icon": "assets/icons/img_7.png", "label": "মাক্রো জব"},
      {"icon": "assets/icons/img_2.png", "label": "স্কিল অর্জন"},
      {"icon": "assets/icons/img_3.png", "label": "রিসেলিং"},
      {"icon": "assets/icons/img_4.png", "label": "ডিজিটাল সার্ভিস"},
      {"icon": "assets/icons/img_5.png", "label": "প্রিমিয়াম অ্যাপ"},
      {"icon": "assets/icons/img_6.png", "label": "সহায় হাত"},
    ];

    // আলাদা স্ক্রিনের লিস্ট
    final List<Widget> screens = [
      MyWorkScreen(),
      DriveOfferScreen(),
      ShowJobGrid(),
      VideoListScreen(),
      ShoppingScreen(),
      DigitalServiceScreen(),
      AppGridScreen(),
      DonationScreen()
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          //childAspectRatio: 0.8,
          // mainAxisSpacing: 5,      // উপরে নিচে স্পেসিং কমানো
          // crossAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          final item = services[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screens[index]),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
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
      {"icon": "💻", "label": "ফ্রি ফ্রিল্যান্সিং"},
      {"icon": "🛍️", "label": "ই-কমার্স"},
      {"icon": "🎁", "label": "সি পি এ মার্কেটিং"},
      {"icon": "🕋", "label": "ফ্রী উমরা হজ্জ"},
      {"icon": "✈️", "label": "এয়ার টিকেট"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingFeatures.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          //childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = upcomingFeatures[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue,
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    // Special handling for telephone links
    if (url.startsWith('tel:')) {
      try {
        // Use LaunchMode.externalApplication specifically for phone calls
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Could not launch phone dialer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    } else {
      // For all other URLs
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback to search
          await launchUrl(Uri.parse('https://www.google.com/search?q=$url'));
        }
      } catch (e) {
        print('Could not launch URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link')),
        );
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
}
