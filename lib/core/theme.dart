import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkThemeColorSchema,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonThemeData,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: lightThemeColorScheme,
  dividerTheme: DividerThemeData(
    color: lightThemeColorScheme.tertiary.withAlpha((0.05 * 255).toInt()),
    space: 0,
  ),
  cardTheme: CardTheme(
      color: const Color.fromARGB(255, 245, 245, 245),
      shadowColor: Colors.transparent),
  elevatedButtonTheme: elevatedButtonThemeData,
  outlinedButtonTheme: outlinedButtonThemeData,
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
  primary: Color(0xFFF2B5D4),
  onPrimary: Colors.white,
  secondary: Color(0xFF202124),
  onSecondary: Colors.white70,
  tertiary: Color(0xFF64B5F6),
  error: Colors.red,
  onError: Colors.black45,
  surface: Color(0xFF121212),
  onSurface: Colors.white,
  inversePrimary: Color(0xFF7BBFF2),
);

final ColorScheme lightThemeColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7BBFF2),
    onPrimary: Colors.white,
    secondary: Color(0xFFEFF7F6),
    onSecondary: Colors.black38,
    tertiary: Colors.black38,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    inversePrimary: Color(0xFFF2B5D4));

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

final OutlinedButtonThemeData outlinedButtonThemeData = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    side: BorderSide(color: lightThemeColorScheme.tertiary),
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
