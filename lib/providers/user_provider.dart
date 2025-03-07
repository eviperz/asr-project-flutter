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
    User? user = await _userService.getUserById("67c6dc96cebfae511c3c7a3a");
    if (user != null) {
      return user;
    }
    return null;
  }
}
