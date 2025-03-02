import 'package:flutter/material.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('উইথড্র'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Balance
            Text(
              'ইনকাম ব্যালেন্স',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('৳ 0.00 BDT', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),


            // TextField for Amount
            TextField(
              decoration: const InputDecoration(
                labelText: 'টাকার পরিমাণ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Text for available balance
            const Text('আপনি পাবেন 0 Tk', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Dropdown for Payment Method
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'পেমেন্ট মেথড',
                border: OutlineInputBorder(),
              ),
              items: <String>['বিকাশ', 'নগদ', 'উপায়']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {},
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  // Handle withdrawal logic
                },
                child: const Text('উইথড্র', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Information
            const Text(
              'পেমেন্ট রিকোয়েস্ট দেওয়ার ২৪ থেকে ৪৮ ঘণ্টার মধ্যে পেমেন্ট করা হবে। সর্বনিম্ন ২৫০ টাকা উইথড্র দিতে পারবেন এবং উইথড্র দেওয়ার সময় ২% চার্জ কেটে নেওয়া হবে, ধন্যবাদ।',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
