import 'dart:developer';

import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  // final Image profile;

  static final Map<String, User> _cache = {};

  User({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> map) {
    if (_cache.containsKey(map['user']['id'])) {
      User cachedUser = _cache[map['user']['id']]!;

      if (cachedUser.id == map['user']['id'] &&
          cachedUser.name == map['user']['name'] &&
          cachedUser.email == map['user']['email'] &&
          cachedUser.imageUrl == map['imageUrl']) {
        return cachedUser;
      }
    }

    User user = User(
      id: map['user']['id'],
      name: map['user']['name'],
      email: map['user']['email'],
      imageUrl: map['imageUrl'],
    );

    _cache[map['user']['id']] = user;

    return user;
  }

  Image getProfile() {
    final Image image = imageUrl != null
        ? Image.network(imageUrl!, fit: BoxFit.cover)
        : Image.asset("assets/images/default-profile.png", fit: BoxFit.cover);
    return image;
  }

  User copyWith({
    String? name,
    String? imageUrl,
  }) {
    return User(
        id: id,
        name: name ?? this.name,
        email: email,
        imageUrl: imageUrl ?? this.imageUrl);
  }

  static User? userFromCache(String id) {
    return _cache[id];
  }
}
