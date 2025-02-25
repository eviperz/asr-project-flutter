import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class Tag {
  final String id;
  final String name;
  final Color color;

  Tag({
    String? id,
    required this.name,
    required this.color,
  }) : id = id ?? Uuid().v4();

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      color: Color(int.parse("0xFF${map['colorCode']}")),
    );
  }
}

class TagDetail {
  final String? name;
  final String? colorCode;

  TagDetail({
    required this.name,
    String? colorCode,
  }) : colorCode = colorCode ?? "C4C4C4";

  Map<String, dynamic> toJson() {
    return {"name": name, "colorCode": colorCode};
  }
}
