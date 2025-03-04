import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class User {
  final String? id;
  final String name;
  final Image profile;

  User(
      {String? id,
      required this.name,
      Image? profile,
      List<String>? diaryFolderIds})
      : id = id ?? Uuid().v4(),
        profile = profile ??
            Image.asset(
              "assets/images/default-profile.png",
              fit: BoxFit.cover,
            );

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
    );
  }
}
