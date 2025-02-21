import 'package:climax_it_user_app/screens/payment_gateway/check.dart';
import 'package:climax_it_user_app/screens/payment_gateway/checkout.dart';
import 'package:climax_it_user_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await WalletService.fetchWalletBalance();
  await FlutterDownloader.initialize(); // Initialize flutter_downloader
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Climax IT',
      theme: themeData,
      //home: SplashScreen(),
      home: CheckUddoktapay(),
    );
  }

  ThemeData themeData = ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'AdorshoLipi',
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: 'AdorshoLipi',
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'AdorshoLipi',
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'AdorshoLipi',
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),

    // appBar theme ====================

    appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue, foregroundColor: Colors.white),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.blue; // বোতাম চাপলে ব্লু হবে
          }
          return Colors.blue; // ডিফল্ট কালার ব্লু
        }),
        textStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'AdorshoLipi', // ফন্ট ফ্যামিলি
            color: Colors.white, // টেক্সট সাদা হবে
          ),
        ),
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return 2.0; // বোতাম চাপলে উঁচুতা কম হবে
          }
          return 6.0; // ডিফল্ট উঁচুতা
        }),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8.0), // বোতামের কোণ গুলো গোল হবে
          ),
        ),
      ),
    ),
  );
}
