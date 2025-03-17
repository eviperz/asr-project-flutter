import 'package:asr_project/config.dart';
import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:asr_project/services/workspace_member_service.dart';
import 'package:asr_project/services/workspace_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final workspaceIdProvider = StateProvider<String?>((ref) {
  return null;
});

// StateNotifier Provider
final workspaceProvider =
    AsyncNotifierProvider<WorkspaceNotifier, List<Workspace>>(() {
  return WorkspaceNotifier();
});

// Notifier Class
class WorkspaceNotifier extends AsyncNotifier<List<Workspace>> {
  final WorkspaceService _workspaceService = WorkspaceService();
  final WorkspaceMemberService _workspaceMemberService =
      WorkspaceMemberService();

  @override
  Future<List<Workspace>> build() async {
    return fetchData();
  }

  Future<List<Workspace>> fetchData() async {
    state = AsyncValue.loading();
    state = AsyncData(await _workspaceService.getAllWorkspaces());
    return state.value ?? [];
  }

  Future<bool> createWorkspace(WorkspaceDetail workspaceDetail) async {
    Workspace? workspace =
        await _workspaceService.createWorkspace(workspaceDetail);
    if (workspace != null) {
      state = AsyncValue.data([...(state.value ?? []), workspace]);
      // _fetchData();
      return true;
    }
    return false;
  }

  Future<Workspace?> updateWorkspace(
      String id, WorkspaceDetail workspaceDetail) async {
    Workspace? workspace =
        await _workspaceService.updateWorkspace(id, workspaceDetail);

    if (workspace != null) {
      state = AsyncData((state.value ?? [])
          .map((item) => item.id == id
              ? item.copyWith(
                  name: workspaceDetail.name ?? item.name,
                  description: workspaceDetail.description ?? item.description)
              : item)
          .toList());
      return workspace;
    }
    return null;
  }

  Future<bool> deleteWorkspace(String id) async {
    final bool response = await _workspaceService.deleteWorkspace(id);

    if (response) {
      state = AsyncData(
        (state.value ?? []).where((w) => w.id != id).toList(),
      );
      return true;
    }
    return false;
  }

  Future<Workspace?> inviteMembers(
      String id, List<WorkspaceMemberInviting> workspaceMemberInvitings) async {
    final Workspace? workspace =
        await _workspaceService.inviteMembers(id, workspaceMemberInvitings);

    if (workspace != null) {
      state = AsyncData((state.value ?? []).map((item) {
        if (item.id != id) {
          return item;
        } else {
          return workspace;
        }
      }).toList());
    }
    return workspace;
  }

  Future<List<Tuple2<User?, WorkspaceMember>>?> updatePermission(
      String workspaceId,
      String workspaceMemberId,
      WorkspacePermission permission) async {
    final bool response = await _workspaceMemberService.updatePermission(
        workspaceMemberId, permission);

    if (response) {
      state = AsyncData((state.value ?? []).map((workspace) {
        if (workspace.id == workspaceId) {
          final List<Tuple2<User?, WorkspaceMember>> updatedMembers =
              workspace.members.map((member) {
            if (member.item2.id == workspaceMemberId) {
              return Tuple2(
                  member.item1, member.item2.copyWith(permission: permission));
            }
            return member;
          }).toList();

          return workspace.copyWith(members: updatedMembers);
        } else {
          return workspace;
        }
      }).toList());
      return state.value?.firstWhere((w) => w.id == workspaceId).members ?? [];
    } else {
      return null;
    }
  }

  Future<bool> acceptMember(String id, String workspaceMemberId) async {
    final bool response =
        await _workspaceMemberService.accept(workspaceMemberId);

    if (response) {
      state = AsyncData(
        (state.value ?? []).map((w) {
          if (w.id != id) return w;

          final List<Tuple2<User?, WorkspaceMember>> updatedMembers = w.members
              .map((member) => member.item2.id == workspaceMemberId
                  ? Tuple2(
                      member.item1,
                      member.item2
                          .copyWith(status: WorkspaceMemberStatus.accepted))
                  : member)
              .toList();

          return w.copyWith(members: updatedMembers);
        }).toList(),
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectMember(String id, String workspaceMemberId) async {
    final bool response =
        await _workspaceMemberService.reject(workspaceMemberId);

    if (response) {
      state = AsyncData(
        (state.value ?? []).map((w) {
          if (w.id != id) return w;

          final List<Tuple2<User?, WorkspaceMember>> updatedMembers = w.members
              .where((member) => member.item2.id != workspaceMemberId)
              .toList();

          return w.copyWith(members: updatedMembers);
        }).toList(),
      );
      return true;
    }
    return false;
  }

  Future<bool> removeMember(String id, String workspaceMemberId) async {
    final bool response =
        await _workspaceMemberService.reject(workspaceMemberId);

    if (response) {
      state = AsyncData(
        (state.value ?? []).map((w) {
          if (w.id != id) return w;

          final List<Tuple2<User?, WorkspaceMember>> updatedMembers = w.members
              .where((member) => member.item2.id != workspaceMemberId)
              .toList();

          return w.copyWith(members: updatedMembers);
        }).toList(),
      );
      return true;
    }
    return false;
  }

  Workspace get workspaceByIdProvider => (state.value ?? [])
      .firstWhere((item) => item.id == ref.read(workspaceIdProvider));

  List<Workspace> get workspacesPending => (state.value ?? [])
      .where((workspace) => workspace.members.any((member) =>
          member.item1?.id == AppConfig.userId &&
          member.item2.status == WorkspaceMemberStatus.pending))
      .toList();
}
