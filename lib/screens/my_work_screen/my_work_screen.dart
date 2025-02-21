import 'package:climax_it_user_app/screens/my_work_screen/task_screen.dart';
import 'package:flutter/material.dart';

class MyWorkScreen extends StatelessWidget {
  const MyWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Works"),
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "প্রিয় গ্রাহক",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "আপনি আমাদের কোর্সটি করার মাধ্যমে আমাদের ভেরিফাইড মেম্বারে পরিণত হয়েছেন। আমরা আপনার জন্য কিছু ছোট ছোট টাস্ক তৈরি করেছি। এর মাধ্যমে আপনি এখনই আপনার উপার্জন শুরু করতে পারেন।  ধন্যবাদ।",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TaskScreen()));
                  },
                  child: Text(
                    "আমার কাজ",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'AdorshoLipi',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
