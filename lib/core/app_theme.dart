import 'package:flutter/material.dart';
class AppTheme {
  static const cyan = Color(0xFF55E7FF);
  static const navy = Color(0xFF070A14);
  static final dark = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: navy,
    colorScheme: ColorScheme.fromSeed(seedColor: cyan, brightness: Brightness.dark),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70), titleLarge: TextStyle(fontWeight: FontWeight.w700)),
  );
}
