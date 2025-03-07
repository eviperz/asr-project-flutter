import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';

class Workspace {
  final String id;
  final String name;
  final String? description;
  final Map<User, WorkspacePermission> members;

  Workspace({
    required this.id,
    required this.name,
    String? description,
    required this.members,
  }) : description = description ?? "";

  factory Workspace.fromJson(Map<String, dynamic> json) {
    List<User> users =
        (json['members'] as List).map((user) => User.fromMap(user)).toList();

    Map<User, WorkspacePermission> members = {};
    (json['workspace']['members'] as Map<String, dynamic>).forEach((id, value) {
      User? user = users.firstWhere((user) => user.id == id);
      members[user] = stringToPermission(value);
    });

    return Workspace(
      id: json['workspace']['id'],
      name: json['workspace']['name'],
      description: json['workspace']['description'] ?? "",
      members: members,
    );
  }
}

class WorkspaceDetail {
  final String? name;
  final String? description;
  final Map<User, WorkspacePermission>? members;
  final List<String>? invitedMemberEmails;

  WorkspaceDetail({
    this.name,
    this.description,
    this.members,
    this.invitedMemberEmails,
  });

  Map<String, dynamic> toJson() {
    Map<String, String> membersMap = {};
    members?.forEach((user, permission) {
      membersMap[user.id] = permissionToString(permission);
    });

    return {
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (members != null) "members": membersMap,
      if (invitedMemberEmails != null)
        "invitedMemberEmails": invitedMemberEmails,
    };
  }
}
