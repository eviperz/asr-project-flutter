import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';

class WorkspaceMember {
  final String id;
  final String email;
  final String workspaceId;
  final WorkspacePermission permission;
  final WorkspaceMemberStatus status;

  const WorkspaceMember({
    required this.id,
    required this.email,
    required this.workspaceId,
    required this.permission,
    required this.status,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['id'],
      email: json['email'],
      workspaceId: json['workspaceId'],
      permission: WorkspacePermission.fromString(json['permission']),
      status: WorkspaceMemberStatus.fromString(json['status']),
    );
  }

  WorkspaceMember copyWith(
      {WorkspacePermission? permission, WorkspaceMemberStatus? status}) {
    return WorkspaceMember(
      id: id,
      email: email,
      workspaceId: workspaceId,
      permission: permission ?? this.permission,
      status: status ?? this.status,
    );
  }
}

class WorkspaceMemberInviting {
  final String email;
  final WorkspacePermission permission;

  const WorkspaceMemberInviting({
    required this.email,
    required this.permission,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "permission": WorkspacePermission.toStringWorkspacePermission(permission),
    };
  }
}
