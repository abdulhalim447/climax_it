import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Define a top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to do any initialization for background messaging, do it here
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  // Note: This is where you would normally implement custom background notification
  // handling if needed
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Stream controller for notification messages received while the app is in the foreground
  final _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();

  // Stream to listen to for notification messages
  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

  Future<void> initialize() async {
    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission on iOS and web
    // For Android, permissions are granted by default
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Save this token to your server to send targeted messages to this device

    // Configure foreground notifications
    await _configureForegroundNotification();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Save this new token to your server
    });
  }

  Future<void> _configureForegroundNotification() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');

        // Add the message to the stream so the UI can show it
        _notificationStreamController.add(message);
      }
    });

    // Handle notification messages when the app is opened from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print(
            'App opened from terminated state with message: ${message.messageId}');
        // Navigate to appropriate screen based on message data
        _handleMessageOpenedApp(message);
      }
    });

    // Handle notification messages when the app is in the background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'App opened from background state with message: ${message.messageId}');
      // Navigate to appropriate screen based on message data
      _handleMessageOpenedApp(message);
    });
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Logic to navigate to specific screen based on message data
    // Example:
    // if (message.data.containsKey('screen')) {
    //   navigateToScreen(message.data['screen']);
    // }
  }

  // Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Dispose method to close the stream controller
  void dispose() {
    _notificationStreamController.close();
  }
}
