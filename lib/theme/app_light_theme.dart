import 'package:flutter/material.dart';

class AppLightTheme {
  static const Color primaryGreen = Color(0xff2e875c); // muted leafy green
  static const Color secondaryGreen = Color(0xFFA8D5BA); // soft mint green
  static const Color background = Color(0xFFF7FBF4); // gentle herb cream
  static const Color cardColor = Color(0xFFE4F0E4); // subtle greenish white
  static const Color accentBrown = Color(0xFF6B4F3B); // soft earthy brown
  static const Color textColor = Color(0xFF1C1C1C); // dark clean gray

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: const Color.fromARGB(255, 72, 92, 80),
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: textColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardColor: cardColor,
      iconTheme: const IconThemeData(color: accentBrown),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: textColor),
        bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
