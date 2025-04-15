import 'package:climax_it_user_app/screens/drive_offer/request_offer.dart';
import 'package:climax_it_user_app/slider/drive_slider.dart';
import 'package:climax_it_user_app/slider/home_screen_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main.dart';

class DriveOfferScreen extends StatefulWidget {
  const DriveOfferScreen({super.key});

  @override
  _DriveOfferScreenState createState() => _DriveOfferScreenState();
}

class _DriveOfferScreenState extends State<DriveOfferScreen> {
  int? operatorId;
  int? categoryId;
  List<dynamic> offers = [];

  final operators = [
    {'id': 1, 'name': 'রবি', 'logo': 'assets/icons/robi.png'},
    {'id': 2, 'name': 'এয়ারটেল', 'logo': 'assets/icons/airtel.png'},
    {'id': 3, 'name': 'বাংলালিংক', 'logo': 'assets/icons/banglalink.png'},
    {'id': 4, 'name': 'গ্রামীণ', 'logo': 'assets/icons/gp.png'},
    {'id': 5, 'name': 'টেলিটক', 'logo': 'assets/icons/teletalk.png'},
    {'id': 6, 'name': 'স্কিটো', 'logo': 'assets/icons/skitto.png'},
  ];

  final categories = [
    {'id': 1, 'name': 'বান্ডেল'},
    {'id': 2, 'name': 'ইন্টারনেট'},
    {'id': 3, 'name': 'মিনিট'},
  ];

  Future<void> fetchOffers() async {
    if (operatorId == null || categoryId == null) return;
    final url =
        'https://climaxitbd.com/php/drive_offer/user/get_offer.php?operator_id=$operatorId&category_id=$categoryId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          offers = json.decode(response.body);
          print(response.body);
        });
      } else {
        setState(() {
          offers = [];
        });
        print('Failed to load offers');
      }
    } catch (e) {
      setState(() {
        offers = [];
      });
      print('Error: $e');
    }
  }

  void _copyOffersList() {
    if (offers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No offers available to copy')),
      );
      return;
    }

    String offerText = offers.map((offer) {
      return '${offer['title']}\n${offer['description']}\nPrice: ${offer['price']} টাকা\n';
    }).join('\n');

    Clipboard.setData(ClipboardData(text: offerText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Offers copied to clipboard')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ড্রাইভ প্যাকেজ'),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyOffersList,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          DriveSlider(),
          SizedBox(height: 10),
          Column(
            children: [
              for (var i = 0; i < operators.length; i += 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var j = i; j < i + 3 && j < operators.length; j++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              operatorId = operators[j]['id'] as int?;
                              fetchOffers();
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: operatorId == operators[j]['id']
                                  ? Colors.blue
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: operatorId == operators[j]['id']
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              operators[j]['logo'] as String,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      categoryId = category['id'] as int?;
                      fetchOffers();
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: categoryId == category['id']
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category['name'] as String,
                      style: TextStyle(
                          color: categoryId == category['id']
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
              child: offers.isEmpty
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          'প্রথমে একটি সিম অফারেটর ও একটি অফার ক্যাটাগরি সিলেক্ট করুন'),
                    ))
                  : ListView.builder(
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];

                        // Find the operator's logo based on the selected operatorId
                        final operator = operators.firstWhere(
                          (op) => op['id'] == operatorId,
                          orElse: () => {'logo': ''}, // Fallback logo
                        );

                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            leading: Image.asset(
                              operator['logo'] as String,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            title: Text(offer['title']),
                            subtitle: Text(
                                '${offer['description']} । \nপ্রাইস: ${offer['price']} টাকা'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestDriveOffer(
                                    id: offer['id'],
                                    title: offer['title'],
                                    description: offer['description'],
                                    price: offer['price'].toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ))
        ],
      ),
    );
  }
}
