import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier Provider
final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});

// Notifier Class
class UserNotifier extends AsyncNotifier<User?> {
  final UserService _userService = UserService();

  @override
  Future<User?> build() async {
    String? userId = await AppConfig.getUserId();
    try {
      if (userId == null) {
        throw Exception("User ID not found. Please log in.");
      }
      User? user = await _userService.getUserById(userId);
      if (user != null) {
        return user;
      }
    } catch (e) {
      return null;
      ;
    }
  }
}
