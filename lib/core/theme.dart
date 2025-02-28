import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  // primaryColor: Colors.black,
  // colorScheme: ColorScheme.dark(
  //   secondary: Colors.white,
  //   tertiary: Colors.white70,
  // ),
  // // scaffoldBackgroundColor: Colors.black,
  // // bottomSheetTheme: BottomSheetThemeData(
  // //   backgroundColor: Colors.transparent,
  // // ),
  // appBarTheme: AppBarTheme(
  //   // backgroundColor: Colors.black,
  //   foregroundColor: Colors.white,
  // ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    titleLarge: TextStyle(),
    titleMedium: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 20,
    ),
    titleSmall: TextStyle(),
  ),
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  // primaryColor: Colors.black,

  // colorScheme: ColorScheme.dark(
  //   secondary: Colors.white,
  //   tertiary: Colors.white70,
  // ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    titleLarge: TextStyle(),
    titleMedium: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 20,
    ),
    titleSmall: TextStyle(),
  ),
);
