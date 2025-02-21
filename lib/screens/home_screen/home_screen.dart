import 'package:climax_it_user_app/screens/app_download/app_download.dart';
import 'package:climax_it_user_app/screens/micro_job/show_job_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/saved_login/user_session.dart';
import '../../slider/home_screen_slider.dart';
import '../course/course_list_page.dart';
import '../digital_service/digital_service.dart';
import '../drive_offer/drive_offer.dart';
import '../my_work_screen/my_work_screen.dart';
import '../shoping/shoping_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

            /*            // স্কল ক্যাটাগরি
            _buildSectionTitle('সবকিছু ক্যাটাগরি'),
            _buildCategoryScroll(),

            // সমস্ত পণ্য
            _buildSectionTitle('সমস্ত পণ্য'),
            _buildProductGrid(),
            */
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
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text('রেফার'),
            onTap: () {
              Navigator.pop(context);
              print('Order History clicked!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.video_camera_front_outlined),
            title: const Text(' আমার ক্লাস'),
            onTap: () {
              Navigator.pop(context);
              print('Order History clicked!');
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('অর্ডার হিস্টোরি'),
            onTap: () {
              Navigator.pop(context);
              print('Order History clicked!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('ট্রানজেকশন হিস্টোরি'),
            onTap: () {
              Navigator.pop(context);
              print('Transaction History clicked!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('শপিং পয়েন্টস'),
            onTap: () {
              Navigator.pop(context);
              print('Shopping Points clicked!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('উইথড্র ব্যালেন্স'),
            onTap: () {
              Navigator.pop(context);
              print('Withdraw Balance clicked!');
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
              Navigator.pop(context);
              _launchURL('tel:+8801928374259');
            },
          ),
          ListTile(
            leading: const Icon(Icons.facebook),
            title: const Text('ফেইসবুক'),
            onTap: () {
              Navigator.pop(context);
              _launchURL('https://www.facebook.com/climaxitbdofficial');
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('ইউটিউব'),
            onTap: () {
              Navigator.pop(context);
              _launchURL('https://www.youtube.com/@ClimaxITBD');
            },
          ),
          ListTile(
            leading: const Icon(Icons.telegram),
            title: const Text('টেলিগ্রাম'),
            onTap: () {
              Navigator.pop(context);
              _launchURL('https://t.me/climaxitbd');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('ইন্সট্রাগ্রাম'),
            onTap: () {
              Navigator.pop(context);
              _launchURL('');
            },
          ),
          ListTile(
            leading: const Icon(Icons.zoom_in_map_outlined),
            title: const Text('এক্স'),
            onTap: () {
              Navigator.pop(context);
              _launchURL('https://x.com/climaxitbd');
            },
          ),

          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('টিকটক'),
            onTap: () {
              Navigator.pop(context);
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
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _idVerificationSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'আইডি ভেরিফাই করুন',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child:
                    const Text('Verify', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
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

      /*
      MacroJobScreen(),
      SkillAchievementScreen(),
      ResellingScreen(),
      DigitalServiceScreen(),*/
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
            onTap: () {
              // আলাদা স্ক্রিনে নেভিগেট করুন
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
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}
