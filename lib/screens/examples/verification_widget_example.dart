import 'package:flutter/material.dart';
import '../../widgets/verification_check.dart';
import '../../widgets/verification_banner.dart';

class VerificationWidgetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Widget Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Show the verification banner at the top
            VerificationBanner(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'This screen demonstrates different ways to use the verification widgets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 2. Example 1: Completely protected content with default message
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example 1: Protected Content (Default)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'This content is completely protected. If not verified, shows verification UI instead of content.'),
                      SizedBox(height: 16),
                      VerificationCheck(
                        // This is the content only shown to verified users
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.green.shade100,
                          child: Text(
                              'This content is only visible to verified users'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Example 2: Protected content with custom message
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example 2: Protected Content (Custom Message)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Protected with custom verification message.'),
                      SizedBox(height: 16),
                      VerificationCheck(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.blue.shade100,
                          child: Text(
                              'This content has a custom verification message'),
                        ),
                        message:
                            "আপনি এই বিশেষ কন্টেন্ট দেখতে চাইলে ভেরিফিকেশন করুন।",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Example 3: Content with placeholder
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example 3: Content with Placeholder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Shows a placeholder for unverified users with tap action.'),
                      SizedBox(height: 16),
                      VerificationCheck(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.purple.shade100,
                          child: Text(
                              'This is premium content for verified users'),
                        ),
                        placeholder: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.grey.shade200,
                          child: Row(
                            children: [
                              Icon(Icons.lock, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Tap to unlock premium content'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Example 4: Non-forced check
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example 4: Non-Forced Check',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Shows content but with verification prompt on tap.'),
                      SizedBox(height: 16),
                      VerificationCheck(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.amber.shade100,
                          child: Row(
                            children: [
                              Text('Tap to interact with this content'),
                              Spacer(),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                        forceCheck: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
