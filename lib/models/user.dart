import 'package:flutter/material.dart';

class User {
  final String username;
  final Image profile;

  User({required this.username, Image? profile})
      : profile = profile ??
            Image.asset(
              "assets/images/default-profile.png",
              fit: BoxFit.cover,
            );
}
