import 'package:flutter/material.dart';
import 'dart:convert'; // for json decoding
import 'package:http/http.dart' as http;


class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  // Fetch notifications from the API
  Future<void> fetchNotifications() async {
    final url = 'https://climaxitbd.com/php/notification/notifiation.php'; // Change with your API URL

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

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('নোটিফিকেশন'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(child: Text('কোনো নোটিফিকেশন পাওয়া যায়নি'))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Card(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(notification['notification'] ?? 'No Message'),
            )),
          );
        },
      ),
    );
  }
}
