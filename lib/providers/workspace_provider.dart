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
    return await _workspaceService.getAllWorkspaces();
  }

  Future<void> _fetchData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _workspaceService.getAllWorkspaces());
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
      state = AsyncValue.data(
          (state.value ?? []).map((d) => d.id == id ? workspace : d).toList());
      _fetchData();
      return workspace;
    }
    return null;
  }

  Future<bool> deleteWorkspace(String id) async {
    final bool response = await _workspaceService.deleteWorkspace(id);

    if (response) {
      state = AsyncValue.data(
        (state.value ?? []).where((w) => w.id != id).toList(),
      );
      return true;
    }
    return false;
  }
}
