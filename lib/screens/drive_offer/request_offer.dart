import 'package:climax_it_user_app/auth/LoginScreen.dart';
import 'package:climax_it_user_app/screens/drive_offer/drive_offer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/verification_provider.dart';


class RequestDriveOffer extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String price;
  final String userId;

  const RequestDriveOffer({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.userId,
  });

  @override
  _RequestDriveOfferState createState() => _RequestDriveOfferState();
}

class _RequestDriveOfferState extends State<RequestDriveOffer> {
  String shoppingWalletBalance = "৳00";
  bool isLoading = false;
  final TextEditingController _offerNumberCoteroller = TextEditingController();
  String? selectedDistrict;

  final List<String> districts = [
    "ঢাকা",
    "চট্টগ্রাম",
    "রাজশাহী",
    "খুলনা",
    "বরিশাল",
    "সিলেট",
    "রংপুর",
    "ময়মনসিংহ"
  ];

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  // API থেকে ইউজারের ওয়ালেট ব্যালেন্স ফেচ করা
  Future<void> _fetchWalletBalance() async {
    if (widget.userId.isEmpty) {
      _showMessage("User not found. Please log in again.");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginScreen()), (route)=> false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(
            "https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "action": "check_balance",
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          shoppingWalletBalance = "৳${responseData['balance']}";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        //_showMessage(responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage("ব্যালেন্স লোড করা সম্ভব হয়নি!");
    }
  }

  // API-তে ব্যালেন্স ডিক্রিজ করার ফাংশন
  Future<void> _deductBalance() async {
    if (_offerNumberCoteroller.text.isEmpty || selectedDistrict == null) {
      _showMessage("অফার নাম্বার ও জেলা নির্বাচন করুন!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    double amount = double.tryParse(widget.price) ?? 0.0;
    try {
      var response = await http.post(
        Uri.parse(
            "https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "action": "deduct_balance",
          "amount": amount,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          shoppingWalletBalance = "৳${responseData['new_balance']}";
        });
        _submitDriveRequest();
      } else {
        setState(() {
          isLoading = false;
        });
        _showMessage(responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage("অফার কেনা সম্ভব হয়নি!");
    }
  }

  //drive offer request pathano
  Future<void> _submitDriveRequest() async {
    try {
      var response = await http.post(
        Uri.parse(
            "https://climaxitbd.com/php/drive_offer/user/userDriveRequest.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "offer_id": widget.id,
          "offer_number": _offerNumberCoteroller.text,
          "district": selectedDistrict,
          "user_id": widget.userId,
        }),
      );

      setState(() {
        isLoading = false;
      });

      var responseData = jsonDecode(response.body);
      if (responseData['success']) {
        insertHistory();
        showCustomDialog(context);
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage("সার্ভারে সমস্যা হয়েছে!");
    }
  }

  Future<void> insertHistory() async {
    if (widget.userId.isEmpty) {
      _showMessage("User ID not found");
      return;
    }

    try {
      final url = Uri.parse("https://climaxitbd.com/php/history.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "description": "আপনার ড্রাইভ অফার অর্ডার সফলভাবে সম্পন্ন হয়েছে!",
        }),
      );

      final result = jsonDecode(response.body);
      // Success is already handled in the calling method
    } catch (e) {
      // Error is already handled in the calling method
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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

                  // Number TextField
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
                        labelText: "বিভাগ নির্বাচন করুন"),
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Consumer<VerificationProvider>(
                        builder: (context, verificationProvider, _) {
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (verificationProvider.isVerified) {
                                      _deductBalance();
                                    } else {
                                      verificationProvider.requireVerification(
                                        context,
                                        message:
                                            "আপনার একাউন্ট ভেরিফাইড নয়। একাউট ভেরিফাই করুন । ধন্যবাদ",
                                        showDialog: true,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'সাবমিট করুন',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Show Custom alert dialog
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                ' আপনার রিকোয়েস্ট একসেপ্ট করা হইয়েছে। পরবর্তী ৩০ মিনিটের মধ্যে অফারটি পেয়ে যাবেন। ধন্যবাদ',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DriveOfferScreen()),
                    (route) => false,
                  ); // Close all screens and navigate to DriveOfferScreen
                },
                child: SizedBox(
                    width: double.maxFinite,
                    child: Center(
                        child: Text(
                      'ঠিক আছে',
                      style: TextStyle(color: Colors.white),
                    ))),
              ),
            ],
          ),
        );
      },
    );
  }
}
