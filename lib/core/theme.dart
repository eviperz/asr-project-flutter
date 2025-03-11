import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonThemeData,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: lightThemeColorScheme,
  dividerTheme: DividerThemeData(color: Colors.black12, space: 0),
  cardTheme: CardTheme(
      color: const Color.fromARGB(255, 245, 245, 245),
      shadowColor: Colors.transparent),
  elevatedButtonTheme: elevatedButtonThemeData,
  chipTheme: chipThemeData,

  // primaryColor: Colors.black,

  // colorScheme: ColorScheme.dark(
  //   secondary: Colors.white,
  //   tertiary: Colors.white70,
  // ),
  textTheme: textTheme,
);

final ColorScheme darkThemeColorSchema = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.indigoAccent,
  onPrimary: Colors.black,
  secondary: Color(0xFFF8F8F8),
  onSecondary: Colors.black38,
  tertiary: Colors.black38,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
);

final ColorScheme lightThemeColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.indigoAccent,
  onPrimary: Colors.white,
  secondary: Color(0xFFF8F8F8),
  onSecondary: Colors.black38,
  tertiary: Colors.black38,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
);

final TextTheme textTheme = TextTheme(
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
  bodyLarge: TextStyle(),
  bodyMedium: TextStyle(),
  bodySmall: TextStyle(),
);

final ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: lightThemeColorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    foregroundColor: lightThemeColorScheme.onPrimary,
  ),
);

final ChipThemeData chipThemeData = ChipThemeData(
  backgroundColor: lightThemeColorScheme.primary,
  labelStyle: textTheme.bodyLarge
      ?.copyWith(color: lightThemeColorScheme.onPrimary)
      .copyWith(
        overflow: TextOverflow.ellipsis,
      ),
  side: BorderSide(
    color: lightThemeColorScheme.onPrimary,
  ),
  deleteIconColor: lightThemeColorScheme.onPrimary,
);
