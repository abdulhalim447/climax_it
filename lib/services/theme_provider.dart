import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String THEME_KEY = 'theme_preference';
  static const String DARK_THEME = 'dark';
  static const String LIGHT_THEME = 'light';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Load saved theme preference
  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePreference = prefs.getString(THEME_KEY);

    if (themePreference == DARK_THEME) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await _saveThemePreference(DARK_THEME);
    } else {
      _themeMode = ThemeMode.light;
      await _saveThemePreference(LIGHT_THEME);
    }

    notifyListeners();
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(THEME_KEY, theme);
  }

  // Get light theme data
  ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.blue;
            }
            return Colors.blue;
          }),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'AdorshoLipi',
              color: Colors.white,
            ),
          ),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return 2.0;
            }
            return 6.0;
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  // Get dark theme data
  ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212), // Dark background
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F), // Darker app bar
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'AdorshoLipi',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'AdorshoLipi',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'AdorshoLipi',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'AdorshoLipi',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.blue.shade700;
            }
            return Colors.blue;
          }),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'AdorshoLipi',
              color: Colors.white,
            ),
          ),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return 2.0;
            }
            return 6.0;
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      // Dark theme specific colors
      cardColor: Color(0xFF1F1F1F),
      dialogBackgroundColor: Color(0xFF1F1F1F),
      dividerColor: Colors.white12,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }
}
