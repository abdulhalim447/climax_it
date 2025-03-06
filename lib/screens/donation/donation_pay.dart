import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class DonationPay extends StatefulWidget {
  final String paymentUrl;
  final String amount;

  const DonationPay({
    super.key,
    required this.paymentUrl,
    required this.amount,
  });

  @override
  _DonationPayState createState() => _DonationPayState();
}

class _DonationPayState extends State<DonationPay> {
  late final WebViewController _controller;

  bool _isLoading = true;
  String responseMessage = '';



  Future<void> _submitDonation() async {
    final String? userID = await UserSession.getUserID();
    final url = Uri.parse('https://climaxitbd.com/php/donation/insert_donation.php'); // আপনার API URL এখানে দিন

    try {
      final response = await http.post(
        url,
        body: {
          'user_id': userID,
          'amount': widget.amount,
        },
      );

      // রেসপন্স চেক করা
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          responseMessage = responseData['message'];
        });
      } else {
        setState(() {
          responseMessage = 'Failed to submit donation.';
        });
      }
    } catch (error) {
      setState(() {
        responseMessage = 'Error: $error';
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        // This is triggered when the page starts loading
        onPageStarted: (String url) {
          print("Page started loading: $url");
          setState(() {
            _isLoading = true;
          });
        },
        // This is triggered when a page finishes loading
        onPageFinished: (String url) {
          print("Page finished loading: $url");
          setState(() {
            _isLoading = false; // পেজ লোড শেষ হলে ইনডিকেটর লুকাও
          });
          // Check if the URL contains 'success.php'
          if (url.contains("success.php")) {
            _submitDonation();
            _closeWebView(
                "Payment Successful!", true); // Call close method on success
          }

          // Check if the URL contains 'cancel'
          else if (url.contains("checkout/cancel")) {
            _closeWebView(
                "Payment Canceled", false); // Call close method on cancel
          }

          // Check if the URL contains 'pending'
          else if (url.contains("pending")) {
            _closeWebView(
                "Payment Pending", false); // Call close method on pending
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          // Log every URL being loaded in the WebView
          print("Navigating to: ${request.url}");

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _closeWebView(String message, bool isSuccess) {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context); // Close WebView
      showSnackBarMessage(message, isSuccess);

      // Navigate to the main screen using Navigator
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const MainBottomNavScreen()),
      // );
    });
  }

  void showSnackBarMessage(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(), // লোডিং ইনডিকেটর
            ),
        ],
      ),
    );
  }
}
