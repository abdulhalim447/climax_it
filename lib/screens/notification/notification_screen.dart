import 'package:climax_it_user_app/widgets/notification_dialog.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('নোটিফিকেশন'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NotificationContent(),
      ),
    );
  }
}
