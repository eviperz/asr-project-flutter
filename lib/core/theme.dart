import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkThemeColorSchema,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: darkThemeColorSchema.primary,
      unselectedItemColor: Colors.white24),
  dividerTheme: DividerThemeData(
    color: darkThemeColorSchema.tertiary.withAlpha((0.05 * 255).toInt()),
    space: 0,
  ),
  cardTheme: CardTheme(
      color: const Color(0xFF373737), shadowColor: Colors.transparent),
  elevatedButtonTheme: elevatedButtonThemeData,
  outlinedButtonTheme: outlinedButtonThemeData,
  chipTheme: chipThemeData,
  textTheme: textTheme,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: lightThemeColorScheme,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: darkThemeColorSchema.primary,
      unselectedItemColor: Colors.black26),
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
  textTheme: textTheme,
);

final ColorScheme darkThemeColorSchema = ColorScheme(
  brightness: Brightness.dark,
  primary: Color.fromARGB(255, 131, 201, 255),
  onPrimary: Colors.white,
  secondary: Color.fromARGB(255, 238, 248, 255),
  onSecondary: Colors.black38,
  tertiary: Colors.white38,
  error: Colors.red,
  onError: Colors.white,
  surface: Color(0xFF262626),
  onSurface: Colors.white,
  inversePrimary: Color.fromARGB(255, 249, 156, 189),
  onInverseSurface: Color(0xFF171717),
);

final ColorScheme lightThemeColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 131, 201, 255),
  onPrimary: Colors.white,
  secondary: Color.fromARGB(255, 238, 248, 255),
  onSecondary: Colors.black38,
  tertiary: Colors.black38,
  error: Colors.red,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
  inversePrimary: Color.fromARGB(255, 249, 156, 189),
  onInverseSurface: Color(0xFF171717),
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

final OutlinedButtonThemeData outlinedButtonThemeData = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    side: BorderSide(
      color: lightThemeColorScheme.primary,
    ),
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
