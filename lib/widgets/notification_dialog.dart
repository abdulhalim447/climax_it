import 'package:climax_it_user_app/widgets/custom_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// A shared notification content widget that can be used by both the dialog and full screen
class NotificationContent extends StatefulWidget {
  const NotificationContent({Key? key}) : super(key: key);

  @override
  NotificationContentState createState() => NotificationContentState();
}

class NotificationContentState extends State<NotificationContent> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  // Fetch notifications from the API
  Future<void> fetchNotifications() async {
    final url = 'https://climaxitbd.com/php/notification/notifiation.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> notificationsData = json.decode(response.body);
        setState(() {
          _notifications = notificationsData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
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

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications when loaded
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CustomCircularIndicator())
        : _notifications.isEmpty
            ? Center(child: Text('কোনো নোটিফিকেশন পাওয়া যায়নি'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final notificationText =
                      notification['notification'] ?? 'No Message';

                  return ListTile(
                    title: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Linkify(
                          onOpen: _onOpen,
                          text: notificationText,
                          style: const TextStyle(color: Colors.black87),
                          linkStyle: const TextStyle(color: Colors.blue),
                          options: const LinkifyOptions(humanize: false),
                        ),
                      ),
                    ),
                  );
                },
              );
  }
}

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => const NotificationDialog(),
    );
  }

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'নোটিফিকেশন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const Divider(),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: NotificationContent(),
          ),
        ],
      ),
    );
  }
}
