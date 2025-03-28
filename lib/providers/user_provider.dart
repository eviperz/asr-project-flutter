import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

// AsyncNotifier Provider
final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});

// Notifier Class
class UserNotifier extends AsyncNotifier<User?> {
  final String baseUrl = "${AppConfig.baseUrl}/auth";
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  final UserService _userService = UserService();

  @override
  Future<User?> build() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/me"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      throw Exception("Failed to fetch user: ${response.statusCode}");
    } catch (e) {
      log("Error fetching user: $e");
      return null;
    }
  }

  Future<void> updateUser({
    String? name,
    File? image,
  }) async {
    User? user = await _userService.updateUser(
      name: name,
      image: image,
    );

    state = AsyncValue.data(
        state.value?.copyWith(name: user?.name, imageUrl: user?.imageUrl));
  }
}
