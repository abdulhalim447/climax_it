import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/firebase_messaging_service.dart';
import '../main.dart';

class PushNotificationHandler extends StatefulWidget {
  final Widget child;

  const PushNotificationHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PushNotificationHandler> createState() =>
      _PushNotificationHandlerState();
}

class _PushNotificationHandlerState extends State<PushNotificationHandler> {
  @override
  void initState() {
    super.initState();
    // Listen for notifications while the app is in foreground
    messagingService.notificationStream.listen(_showNotification);
  }

  void _showNotification(RemoteMessage message) {
    // Show a simple SnackBar notification when a message is received
    if (message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification!.title ?? 'New Notification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(message.notification!.body ?? ''),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Here you can navigate to a specific screen based on the message
              // For example: Navigate to a notification details screen
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simply return the child - the listener is just for notifications
    return widget.child;
  }
}
