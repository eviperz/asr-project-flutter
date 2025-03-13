import 'dart:developer';

import 'package:asr_project/models/enum/color_platte.dart';

class Tag {
  final String id;
  final String name;
  final ColorPalette colorEnum;

  Tag({
    required this.id,
    required this.name,
    required this.colorEnum,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['tagId'],
      name: json['tagName'],
      colorEnum: ColorPalette.fromHex(json['colorCode']),
    );
  }
}

class TagDetail {
  final String? name;
  final ColorPalette? colorEnum;

  TagDetail({
    this.name,
    this.colorEnum,
  });

  Map<String, dynamic> toJson() {
    if (colorEnum != null) log(colorEnum!.hexCode.toString());
    return {
      if (name != null) "tagName": name,
      if (colorEnum != null) "colorCode": colorEnum?.hexCode,
    };
  }
}
