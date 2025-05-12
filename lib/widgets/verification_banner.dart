import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';
import '../widgets/web_view.dart';

class VerificationBanner extends StatelessWidget {
  final bool showIfVerified;

  const VerificationBanner({
    Key? key,
    this.showIfVerified = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, verificationProvider, child) {
        // If verified and not showing verified banner, return empty container
        if (verificationProvider.isVerified && !showIfVerified) {
          return const SizedBox.shrink();
        }

        // If loading, show loading indicator
        if (verificationProvider.status == VerificationStatus.loading) {
          return const SizedBox.shrink();
        }

        // If verified and showing verified banner
        if (verificationProvider.isVerified && showIfVerified) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'আপনার একাউন্ট ভেরিফাইড!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // If not verified, show verification banner
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'আপনার একাউন্টটি ভেরিফাই করুন!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'আমাদের সকল সার্ভিস ব্যবহার করতে আপনার একাউন্টটি ভেরিফাই করুন। ধন্যবাদ।',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    String? paymentUrl = await verificationProvider
                        .initiateVerification(amount: '500');
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
                    'ভেরিফাই করুন',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
