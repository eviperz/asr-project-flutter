import 'package:flutter/material.dart';

enum ColorPalette {
  red("FF5733", Colors.red),
  orange("FF8C42", Colors.orange),
  yellow("FFC300", Colors.yellow),
  green("28A745", Colors.green),
  blue("007BFF", Colors.blue),
  purple("6F42C1", Colors.purple),
  pink("E83E8C", Colors.pink),
  teal("20C997", Colors.teal),
  gray("6C757D", Colors.grey);

  final String hexCode;
  final Color color;

  const ColorPalette(this.hexCode, this.color);

  static Color hexToColor(String hex) {
    return Color(int.parse("0xFF$hex"));
  }

  /// Find a color by its hex code
  static ColorPalette fromHex(String hex) {
    return ColorPalette.values.firstWhere(
      (e) => e.hexCode.toLowerCase() == hex.toLowerCase(),
      orElse: () => ColorPalette.gray,
    );
  }
}
