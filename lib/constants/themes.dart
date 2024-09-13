import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF2E478A),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: const Color(0xFFF8F260), // Replaces `accentColor`
  ),
  scaffoldBackgroundColor: const Color(0xFF111826), // Replaces `backgroundColor`
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1C1C1C),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1C1C1C),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1C1C1C),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1C1C1C),
    ),
    labelSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF1C1C1C),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFFFFF),
    ),
  ),
);
