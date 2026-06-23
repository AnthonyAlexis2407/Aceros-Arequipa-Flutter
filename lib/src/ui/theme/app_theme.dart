import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF001B5A);
  static const Color primaryLight = Color(0xFF0A3D91);
  static const Color secondary = Color(0xFF2196F3);
  static const Color surface = Color(0xFFF2F7FF);
  static const Color background = Color(0xFFFFFFFF);
}

final ColorScheme appColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.light,
).copyWith(
  secondary: AppColors.secondary,
  surface: AppColors.surface,
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: appColorScheme,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.primary,
    selectedItemColor: Colors.white,
    unselectedItemColor: Color(0xFFBFCFEF),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);
