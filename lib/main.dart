import 'package:climax_it_user_app/screens/splash_screen/splash_screen.dart';
import 'package:climax_it_user_app/widgets/custom_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/theme_provider.dart';
import 'widgets/notification_listener.dart';

import 'auth/verification/verification_service.dart';

final VerificationService verificationService = VerificationService();
final FirebaseMessagingService messagingService = FirebaseMessagingService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await WalletService.fetchWalletBalance();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging Service
  await messagingService.initialize();

  // Wait for the verification process
  await verificationService.initialize();
  await FlutterDownloader.initialize(); // Initialize flutter_downloader

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Climax IT',
      theme: themeProvider.getLightTheme(),
      darkTheme: themeProvider.getDarkTheme(),
      home: PushNotificationHandler(
        child: SplashScreen(),
      ),
    );
  }
}
