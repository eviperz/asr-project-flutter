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
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.indigoAccent,
    onPrimary: Colors.white,
    secondary: Colors.black54,
    onSecondary: Colors.white,
    tertiary: Colors.black38,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  dividerTheme: DividerThemeData(color: Colors.black12),
  cardTheme: CardTheme(
      color: const Color.fromARGB(255, 245, 245, 245),
      shadowColor: Colors.transparent),

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
