import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        // This is triggered when the page starts loading
        onPageStarted: (String url) {
          print("Page started loading: $url");


        },
        // This is triggered when a page finishes loading
        onPageFinished: (String url) {
          print("Page finished loading: $url");
          // Check if the URL contains 'success.php'
          if (url.contains("success.php")) {
            _closeWebView("Payment Successful!", true); // Call close method on success
          }

          // Check if the URL contains 'cancel'
          else if (url.contains("checkout/cancel")) {
            _closeWebView("Payment Canceled", false); // Call close method on cancel
          }

          // Check if the URL contains 'pending'
          else if (url.contains("pending")) {
            _closeWebView("Payment Pending", false); // Call close method on pending
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
      body: WebViewWidget(controller: _controller),
    );
  }
}
