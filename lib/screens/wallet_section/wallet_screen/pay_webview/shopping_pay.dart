import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class ShoppingPay extends StatefulWidget {
  final String paymentUrl;
  final String amount;

  const ShoppingPay({
    super.key,
    required this.paymentUrl,
    required this.amount,
  });

  @override
  _ShoppingPayState createState() => _ShoppingPayState();
}

class _ShoppingPayState extends State<ShoppingPay> {
  late final WebViewController _controller;

  bool _isLoading = true;
  String responseMessage = '';



  Future<void> updateWalletBalance() async {
    // Get values from text controllers
    final String? userId = await UserSession.getUserID();

    // Define the URL of your PHP script
    String url = 'https://climaxitbd.com/php/wallet/increase-shop-balance.php'; // Replace with your PHP script URL

    // Prepare JSON data
    Map<String, dynamic> data = {
      'user_id': userId,
      'shopping_wallet_balance': widget.amount,
    };

    // Send the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response
        Map<String, dynamic> responseData = json.decode(response.body);

        // Display the response in the UI
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        // Handle non-200 status code
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update wallet balance'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> insertHistory() async {
    final String? userID = await UserSession.getUserID();

    if (userID!.isEmpty) {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User ID not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final url = Uri.parse("https://climaxitbd.com/php/history.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userID,
        "description": "আপনি ${widget.amount} টাকা পেমেন্ট সম্পন্ন করেছেন!",
      }),
    );

    final result = jsonDecode(response.body);
    print(result["message"]);
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
            updateWalletBalance();
            insertHistory();
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
