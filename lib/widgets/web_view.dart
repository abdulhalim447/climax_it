import 'dart:convert';

import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
  });

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  bool _isLoading = true;

  Future<void> _updateWallet() async {
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

    try {
      final url = Uri.parse('https://climaxitbd.com/php/wallet/verify_pay.php');

      Map<String, dynamic> data = {
        'user_id': userID,
        'shopping_wallet_balance': "10",
        'isVarified': "1",
      };

      final response = await http.post(url, body: json.encode(data), headers: {
        'Content-Type': 'application/json',
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Exception handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
            _updateWallet();
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
