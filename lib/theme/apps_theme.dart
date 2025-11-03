// app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF6F61),
      secondary: Color(0xFF1DD1A1),
      surface: Color(0xFFF5F6FA),
      background: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF2C3E50),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF6F61),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: "Signatra",
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1DD1A1),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: "Poppins",
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
      bodyMedium: TextStyle(fontFamily: "Poppins", color: Color(0xFF2C3E50)),
    ),

    // <-- Usar CardThemeData em vez de CardTheme (compatível com versões mais recentes)
    cardTheme: CardThemeData(
      color: const Color(0xFFF5F6FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      // Se quiseres adicionar sombra personalizada, usa shadowColor/padding conforme necessário
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF6F61),
      secondary: Color(0xFF1DD1A1),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF6F61),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: "Signatra",
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1DD1A1),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: "Poppins",
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontFamily: "Poppins", color: Colors.white70),
    ),

    // <-- CardThemeData também no dark theme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
    ),
  );
}
