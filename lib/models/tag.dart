import 'package:flutter/widgets.dart';

class Tag {
  final String id;
  final String name;
  final Color color;

  Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['tagId'],
      name: map['tagName'],
      color: Color(int.parse("0xFF${map['colorCode']}")),
    );
  }
}

class TagDetail {
  final String name;
  final String? colorCode;

  TagDetail({
    required this.name,
    String? colorCode,
  }) : colorCode = colorCode ?? "C4C4C4";

  Map<String, dynamic> toJson() {
    return {"tagName": name, "colorCode": colorCode,};
  }
}
