import 'package:climax_it_user_app/screens/micro_job/submit_proof.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/verification_provider.dart';

class MicroWorkScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const MicroWorkScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final verificationProvider =
        Provider.of<VerificationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('মাইক্রো জব বিবরণ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Payment Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['price'] + 'tk'),
                  Text(item['task_id']),
                  Text('0/0'),
                ],
              ),
              SizedBox(height: 10),

              // Image Section
              Align(
                alignment: Alignment.center,
                child: Image.network(item['thumbnail'], height: 250),
              ),
              SizedBox(height: 16),

              // Title Text
              Text(
                item['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              // Buttons
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () async {
                    if (verificationProvider.isVerified) {
                      if (await canLaunch(item['work_link'])) {
                        await launch(item['work_link']);
                      } else {
                        throw 'Could not launch ${item['work_link']}';
                      }
                    } else {
                      verificationProvider.requireVerification(
                        context,
                        message:
                            "আপনার একাউন্ট ভেরিফাইড নয়। একাউট ভেরিফাই করুন । ধন্যবাদ",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    'কাজ শুরু করুন',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    if (verificationProvider.isVerified) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImageUploadScreen(taskID: item['task_id'])));
                    } else {
                      verificationProvider.requireVerification(
                        context,
                        message:
                            "আপনার একাউন্ট ভেরিফাইড নয়। একাউট ভেরিফাই করুন । ধন্যবাদ",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('প্রুফ সাবমিট করুন',
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              SizedBox(height: 10),

              // Description Text
              Text(
                item['description'],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
