import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  // URL বা যোগাযোগ লিংকগুলো
  final List<Map<String, String>> supportLinks = [
    {
      'name': 'হোয়াটসঅ্যাপ',
      'icon': 'assets/icons/whatsapp.png', // WhatsApp এর লোগো
      'url': 'https://wa.me/+8801928374259', // আপনার WhatsApp নম্বরের লিংক
    },
    {
      'name': 'টেলিগ্রাম',
      'icon': 'assets/icons/telegram.png', // WhatsApp এর লোগো
      'url': 'https://t.me/climaxitbd', // আপনার WhatsApp নম্বরের লিংক
    },
    {
      'name': 'ফেইসবুক',
      'icon': 'assets/icons/facebook.png', // Facebook Messenger এর লোগো
      'url': 'https://www.facebook.com/climaxitbdofficial', // আপনার Messenger লিংক
    },
    {
      'name': 'টিকটক',
      'icon': 'assets/icons/tiktok.png', // Email আইকন
      'url': 'https://www.tiktok.com/@climaxit', // আপনার সাপোর্ট ইমেইল
    }, {
      'name': 'এক্স',
      'icon': 'assets/icons/twitter.png', // Email আইকন
      'url': 'https://x.com/climaxitbd', // আপনার সাপোর্ট ইমেইল
    },
    {
      'name': 'ফোন',
      'icon': 'assets/icons/call.png', // কল আইকন
      'url': 'tel:+8801928374259', // আপনার ফোন নম্বর
    },
  ];

  // URL ওপেন করার ফাংশন
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('সাপোর্ট'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Align(alignment: Alignment.center, child: Icon(Icons.support_agent, size: 80,)),
            SizedBox(height: 10),

            Text(
              'সার্ভিসটি গ্রহণ করতে সরাসরি যোগাযোগ করুন নিচের যে কোনো মাধ্যমে। ধন্যবাদ।',

              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
              ),

              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // সাপোর্ট লিংকগুলো শো করা হচ্ছে
            Expanded(
              child: ListView.builder(
                itemCount: supportLinks.length,
                itemBuilder: (context, index) {
                  final support = supportLinks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: InkWell(
                      onTap: () => _launchURL(support['url']!),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: Image.asset(
                          support['icon']!,
                          height: 30,
                          width: 30,
                        ),
                        title: Text(
                          support['name']!,
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
