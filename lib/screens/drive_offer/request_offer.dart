import 'package:climax_it_user_app/screens/drive_offer/drive_offer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/saved_login/user_session.dart';

class RequestDriveOffer extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String price;

  RequestDriveOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  _RequestDriveOfferState createState() => _RequestDriveOfferState();
}

class _RequestDriveOfferState extends State<RequestDriveOffer> {
  String shoppingWalletBalance = "৳00";
  String userId = "";
  final TextEditingController _offerNumberCoteroller = TextEditingController();
  String? selectedDistrict;

  final List<String> districts = [
    "ঢাকা", "চট্টগ্রাম", "রাজশাহী", "খুলনা",
    "বরিশাল", "সিলেট", "রংপুর", "ময়মনসিংহ"
  ];



  @override
  void initState() {
    super.initState();
    _loadUserId();

  }

  // ইউজারের ID লোড করার ফাংশন
  Future<void> _loadUserId() async {

    final String?  userID = await UserSession.getUserID();
    setState(() {
      userId = userID!;
    });

    if (userId.isNotEmpty) {
      _fetchWalletBalance(); // ইউজারের ব্যালেন্স চেক করবো
    }
  }

  // API থেকে ইউজারের ওয়ালেট ব্যালেন্স ফেচ করা
  Future<void> _fetchWalletBalance() async {
    try {
      var response = await http.post(
        Uri.parse("https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "action": "check_balance",
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          shoppingWalletBalance = "৳${responseData['balance']}";
        });
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("ব্যালেন্স লোড করা সম্ভব হয়নি!");
    }
  }



  // API-তে ব্যালেন্স ডিক্রিজ করার ফাংশন
  Future<void> _deductBalance() async {
    double amount = double.tryParse(widget.price) ?? 0.0;
    try {
      var response = await http.post(

        Uri.parse("https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},


        body: jsonEncode({
          "user_id": userId,
          "action": "deduct_balance",
          "amount": amount,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          shoppingWalletBalance = "৳${responseData['new_balance']}";
        });
        //print(responseData['message']);
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("অফার কেনা সম্ভব হয়নি!");
    }
  }

  //drive offer request pathano
  Future<void> _submitDriveRequest() async {
    if (_offerNumberCoteroller.text.isEmpty || selectedDistrict == null) {
      _showMessage("অফার নাম্বার ও জেলা নির্বাচন করুন!");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("https://climaxitbd.com/php/drive_offer/user/userDriveRequest.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "offer_id": widget.id,
          "offer_number": _offerNumberCoteroller.text,
          "district": selectedDistrict,
          "user_id": userId,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['success']) {
        showCustomDialog(context);
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("সার্ভারে সমস্যা হয়েছে!");
    }
  }


  // মেসেজ দেখানোর ফাংশন
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ড্রাইভ অফার কিনুন"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Shopping Wallet Balance
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'শপিং ব্যালেন্স: $shoppingWalletBalance টাকা',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "অফার: ${widget.title}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "বর্ণনা: ${widget.description}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "মূল্য: ${widget.price} টাকা",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Name TextField
            TextField(
              controller: _offerNumberCoteroller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "অফার নাম্বার",
                border: OutlineInputBorder(),

              ),
            ),
            SizedBox(height: 20),

            // Division Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              items: districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "জেলা নির্বাচন করুন"),
            ),
            SizedBox(height: 20),

            // Submit Button
            Center(
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed:(){
                    _submitDriveRequest();
                    _deductBalance();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    "সাবমিট",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Show Custom  alert dialogeu
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(' আপনার রিকোয়েস্ট একসেপ্ট করা হইয়েছে। পরবর্তী ৩০ মিনিটের মধ্যে অফারটি পেয়ে যাবেন। ধন্যবাদ', style: TextStyle(fontSize: 16),),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DriveOfferScreen())); // Close the dialog
                },
                child: SizedBox(
                  width: double.maxFinite,
                    child: Center(child: Text('ঠিক আছে', style: TextStyle(color: Colors.white),))),
              ),
            ],
          ),
        );
      },
    );
  }

}
