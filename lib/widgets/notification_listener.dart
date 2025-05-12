import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Open URL when tapped
  Future<void> _onOpen(LinkableElement link) async {
    final Uri uri = Uri.parse(link.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to search
        await launchUrl(
            Uri.parse('https://www.google.com/search?q=${link.url}'));
      }
    } catch (e) {
      print("Could not launch URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  void _showNotification(RemoteMessage message) {
    // Show a simple SnackBar notification when a message is received
    if (message.notification != null) {
      final title = message.notification!.title ?? 'New Notification';
      final body = message.notification!.body ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Linkify(
                onOpen: _onOpen,
                text: body,
                style: const TextStyle(color: Colors.white),
                linkStyle: const TextStyle(
                  color: Colors.lightBlueAccent,
                  decoration: TextDecoration.underline,
                ),
                options: const LinkifyOptions(humanize: false),
              ),
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
