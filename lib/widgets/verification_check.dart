import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';
import '../widgets/web_view.dart';

class VerificationCheck extends StatelessWidget {
  final Widget child;
  final Widget? placeholder;
  final bool forceCheck;
  final String message;
  
  const VerificationCheck({
    Key? key,
    required this.child,
    this.placeholder,
    this.forceCheck = true,
    this.message = "আপনার একাউন্ট ভেরিফাইড নয়। একাউট ভেরিফাই করুন । ধন্যবাদ",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, verificationProvider, _) {
        if (verificationProvider.isVerified) {
          return child;
        }
        
        if (placeholder != null) {
          return GestureDetector(
            onTap: () => _showVerificationPrompt(context, verificationProvider),
            child: placeholder!,
          );
        }
        
        if (forceCheck) {
          // Show verification required message with action buttons
          return Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initiateVerification(context, verificationProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'ভেরিফাই করুন',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // If not forcing verification check, just show the child with a snackbar on tap
        return GestureDetector(
          onTap: () => _showVerificationSnackbar(context, verificationProvider),
          child: child,
        );
      },
    );
  }
  
  void _showVerificationPrompt(BuildContext context, VerificationProvider provider) {
    provider.requireVerification(context, message: message, showDialog: true);
  }
  
  void _showVerificationSnackbar(BuildContext context, VerificationProvider provider) {
    provider.requireVerification(context, message: message, showDialog: false);
  }
  
  Future<void> _initiateVerification(BuildContext context, VerificationProvider provider) async {
    String? paymentUrl = await provider.initiateVerification(amount: '500');
    if (paymentUrl != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            paymentUrl: paymentUrl,
          )
        ),
      );
    }
  }
} 