import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D42BD);
  static const Color secondaryColor = Color(0xFF3474EB);
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
} 