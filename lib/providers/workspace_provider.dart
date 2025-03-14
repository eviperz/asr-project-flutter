import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/services/workspace_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      state = AsyncData(
          (state.value ?? []).map((d) => d.id == id ? workspace : d).toList());
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

  Future<bool> removeMember(
      String id, Map<String, String> removedUserId) async {
    final bool response =
        await _workspaceService.removeMember(id, removedUserId);

    if (response) {
      state = AsyncData(
        (state.value ?? []).map((w) {
          if (w.id != id) return w;

          final updatedMembers = Map.of(w.members)
            ..removeWhere((key, value) => removedUserId.containsKey(key));

          return w.copyWith(members: updatedMembers);
        }).toList(),
      );
      return true;
    }
    return false;
  }

  Workspace get workspaceByIdProvider => (state.value ?? [])
      .firstWhere((item) => item.id == ref.read(workspaceIdProvider));
}
