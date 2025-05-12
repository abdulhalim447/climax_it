import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../auth/saved_login/user_session.dart';
import '../auth/verification/verification_service.dart';
import '../widgets/web_view.dart';

enum VerificationStatus { loading, verified, notVerified, error }

class VerificationProvider extends ChangeNotifier {
  final VerificationService _verificationService = VerificationService();
  VerificationStatus _status = VerificationStatus.loading;
  String? _userId;
  String? _email;
  String? _name;
  Timer? _refreshTimer;

  // Getters
  VerificationStatus get status => _status;

  bool get isVerified => _status == VerificationStatus.verified;

  String? get userId => _userId;

  String? get email => _email;

  String? get name => _name;

  // Constructor - Initialize verification when provider is created
  VerificationProvider() {
    initialize();
  }

  // Initialize user data and verification status
  Future<void> initialize() async {
    _status = VerificationStatus.loading;
    notifyListeners();

    await _loadUserInfo();
    await refreshVerificationStatus();

    // Set up a periodic refresh (every 15 minutes)
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      refreshVerificationStatus();
    });
  }

  // Load user information from session
  Future<void> _loadUserInfo() async {
    try {
      _userId = await UserSession.getUserID();
      _email = await UserSession.getEmail();
      _name = await UserSession.getName();
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  // Refresh verification status from server
  Future<void> refreshVerificationStatus() async {
    if (_userId == null || _userId!.isEmpty) {
      _status = VerificationStatus.notVerified;
      notifyListeners();
      return;
    }

    try {
      final isVerified = await _verificationService.checkVerification();
      _status = isVerified
          ? VerificationStatus.verified
          : VerificationStatus.notVerified;
    } catch (e) {
      print("Error refreshing verification status: $e");
      _status = VerificationStatus.error;
    }

    notifyListeners();
  }

  // Initiate the verification process with payment
  Future<String?> initiateVerification({required String amount}) async {
    if (_userId == null || _email == null || _name == null) {
      return null;
    }

    return await _verificationService.initiateVerification(
        _name!, _email!, amount, _userId!);
  }

  // Handle verification UI based on status
  Future<bool> requireVerification(
    BuildContext context, {
    String message = "আপনার একাউন্ট ভেরিফাইড নয়। একাউট ভেরিফাই করুন । ধন্যবাদ",
    bool showDialog = true,
  }) async {
    if (isVerified) return true;

    if (showDialog) {
      final result = await showVerificationDialog(context, message);
      if (result == true) {
        // User chose to verify
        String? paymentUrl = await initiateVerification(amount: '500');
        if (paymentUrl != null) {
          // Navigate to payment webview
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentWebView(
                        paymentUrl: paymentUrl,
                      )));
          return false; // Not verified yet
        }
      }
    } else {
      // Just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Verify',
            textColor: Colors.white,
            onPressed: () async {
              String? paymentUrl = await initiateVerification(amount: '500');
              if (paymentUrl != null && context.mounted) {
                // Navigate to payment webview
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentWebView(
                              paymentUrl: paymentUrl,
                            )));
              }
            },
          ),
        ),
      );
    }

    return false; // Not verified
  }

  // Show a dialog for verification
  Future<bool?> showVerificationDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              String? paymentUrl = await initiateVerification(amount: '500');
              if (paymentUrl != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentWebView(
                        paymentUrl: paymentUrl,
                      )),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Verify Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
