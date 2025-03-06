import 'package:climax_it_user_app/screens/donation/donation_pay.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // JSON parsing
import 'package:http/http.dart' as http;

import '../../auth/saved_login/user_session.dart';


class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController _amountController = TextEditingController();
  late int totalDonations = 0;
  late String description = '';
  late List<String> imageLinks = [];

  @override
  void initState() {
    super.initState();
    fetchDonationData();
    _userInfo();
  }

  String userId = "";
  String name = "";
  String email = "";

  Future<void> _userInfo() async {
    try {
      String? fetchedUserId = await UserSession.getUserID();
      String? fetchedEmail = await UserSession.getEmail();
      String? fetchedName = await UserSession.getName();

      if (fetchedUserId != null &&
          fetchedEmail != null &&
          fetchedName != null) {
        setState(() {
          userId = fetchedUserId;
          email = fetchedEmail;
          name = fetchedName;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DonationPay(
                paymentUrl: data['payment_url'], amount: _amountController.text,
              )),
        );
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> fetchDonationData() async {
    final url =
    Uri.parse('https://climaxitbd.com/php/donation/get_donate_persons.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          totalDonations = int.parse(data[0]['total_donations']);
          description = data[0]['description'];
          imageLinks = List<String>.from(data[0]['image_links']);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleDonation() {
    final amount = _amountController.text;
    if (amount.isNotEmpty) {
      createCheckout(
        fullName: name,
        email: email,
        amount: amount, // Send dynamic amount
        userId: userId,
        orderId: '', // Optionally, you can provide an orderId
      );
    } else {
      // Handle the case where no amount is entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a donation amount")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Screen')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display total donations in a Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Donations: $totalDonations',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description: $description',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Display images of previous donations in a Card
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: imageLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(child: Image.network(link, fit: BoxFit.cover)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // TextField for donation amount
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Enter Donation Amount',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: _handleDonation,
                  child: const Text(
                    'Help',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
