import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final Image profile;

  static final Map<String, User> _cache = {};

  User({
    required this.id,
    required this.name,
    required this.email,
    Image? profile,
  }) : profile = profile ??
            Image.asset(
              "assets/images/default-profile.png",
              fit: BoxFit.cover,
            );

  factory User.fromJson(Map<String, dynamic> map) {
    if (_cache.containsKey(map['id'])) {
      User cachedUser = _cache[map['id']]!;

      if (cachedUser.id == map['id'] &&
          cachedUser.name == map['name'] &&
          cachedUser.email == map['email']) {
        return cachedUser;
      }
    }

    User user = User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );

    _cache[map['id']] = user;

    return user;
  }

  static User? userFromCache(String id) {
    return _cache[id];
  }
}
