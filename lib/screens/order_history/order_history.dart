import 'package:flutter/material.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('অর্ডার হিস্ট্রি'),),
      
      
      body: Center(
        child: Text('কোনো হিস্ট্রি পাওয়া যায়নি', style: TextStyle(fontSize: 14),),
      ),
    );
  }
}
