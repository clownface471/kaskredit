import 'package:flutter/material.dart';

class AppTheme {
  // 1. Skema Warna (Sesuai Blueprint)
  //
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color lightBgColor = Color(0xFFFAFAFA); // Light Grey
  static const Color surfaceColor = Color(0xFFFFFFFF); // White

  // 2. Skala Tipografi (Sesuai Blueprint)
  //
  static const TextTheme appTextTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5), // Untuk tombol
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  // 3. Tema Utama Aplikasi
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Terapkan Skema Warna
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBgColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: lightBgColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),

      // Terapkan Tipografi
      textTheme: appTextTheme,

      // Kustomisasi Komponen UI
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        color: surfaceColor,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: appTextTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: appTextTheme.labelMedium,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),

      bottomAppBarTheme: const BottomAppBarThemeData(
        color: surfaceColor,
        elevation: 8,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black,
      ),
    );
  }
}