import 'package:asr_project/models/user.dart';
import 'package:uuid/uuid.dart';

class Workspace {
  final String? id;
  final String name;
  final User owner;
  final List<User> users;

  Workspace(
      {String? id, required this.name, required this.owner, List<User>? users})
      : id = id ?? Uuid().v4(),
        users = users ?? [];
}
