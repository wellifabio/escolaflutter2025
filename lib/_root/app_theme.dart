import 'package:escolaflutter2023/_root/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  // Tema Claro (original)
  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.c1,
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        color: AppColors.c4,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.c1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.c5),
      labelStyle: TextStyle(color: AppColors.c4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.c4,
        foregroundColor: AppColors.c1,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.c1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.c1,
      titleTextStyle: TextStyle(
        color: AppColors.c4,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: AppColors.c3, fontSize: 16),
      iconColor: AppColors.c4,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.c4),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.c4),
      bodyMedium: TextStyle(color: AppColors.c4),
      bodySmall: TextStyle(color: AppColors.c4),
    ),
  );

  // Tema Escuro (cores invertidas)
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.c4,
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        color: AppColors.c1,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ), // Invertido: c4 ao invés de c1
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.c4,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.c5),
      labelStyle: TextStyle(color: AppColors.c1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.c1, // Invertido: c1 ao invés de c4
        foregroundColor: AppColors.c4, // Invertido: c4 ao invés de c1
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.c4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.c4,
      titleTextStyle: TextStyle(
        color: AppColors.c1,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: AppColors.c2, fontSize: 16),
      iconColor: AppColors.c1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.c1),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.c1),
      bodyMedium: TextStyle(color: AppColors.c1),
      bodySmall: TextStyle(color: AppColors.c1),
    ),
  );

  // Mantém compatibilidade com código existente
  static ThemeData appTheme = lightTheme;
}
