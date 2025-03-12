import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace_icon_model.dart';

class Workspace {
  final String id;
  final String name;
  final String? description;
  final WorkspaceIconModel icon;
  final Map<User, WorkspacePermission> members;

  Workspace({
    required this.id,
    required this.name,
    required this.icon,
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
      icon: WorkspaceIconModel.fromJson(json['workspace']['icon']),
      members: members,
    );
  }

  Workspace copyWith(
      {String? id,
      String? name,
      String? description,
      Map<User, WorkspacePermission>? members}) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: this.icon,
      members:
          members ?? this.members,
    );
  }
}

class WorkspaceDetail {
  final String? name;
  final String? description;
  final WorkspaceIconDetail? icon;
  final Map<User, WorkspacePermission>? members;
  final List<String>? invitedMemberEmails;

  WorkspaceDetail({
    this.name,
    this.description,
    this.icon,
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
      if (icon != null) "icon": icon?.toJson(),
      if (members != null) "members": membersMap,
      if (invitedMemberEmails != null)
        "invitedMemberEmails": invitedMemberEmails,
    };
  }
}
