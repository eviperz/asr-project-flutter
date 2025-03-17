import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace_icon_model.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:tuple/tuple.dart';

class Workspace {
  final String id;
  final String name;
  final String? description;
  final WorkspaceIconModel icon;
  final List<Tuple2<User?, WorkspaceMember>> members;

  Workspace({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.members,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    List<Tuple2<User?, WorkspaceMember>> members = [];
    for (final member in json['members']) {
      User? user =
          member['user'] != null ? User.fromJson(member['user']) : null;
      WorkspaceMember workspaceMember =
          WorkspaceMember.fromJson(member['workspaceMember']);

      members.add(Tuple2(user, workspaceMember));
    }

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
      List<Tuple2<User?, WorkspaceMember>>? members}) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon,
      members: members ?? this.members,
    );
  }
}

class WorkspaceDetail {
  final String? name;
  final String? description;
  final WorkspaceIconDetail? icon;
  final List<WorkspaceMemberInviting>? members;

  WorkspaceDetail({
    this.name,
    this.description,
    this.icon,
    this.members,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (icon != null) "icon": icon?.toJson(),
      if (members != null) "members": members?.map((e) => e.toJson()).toList(),
    };
  }
}
