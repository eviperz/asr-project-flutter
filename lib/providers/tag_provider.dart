import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/services/tag_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier Provider
final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(
  () => TagsNotifier(),
);

// Notifier Class
class TagsNotifier extends AsyncNotifier<List<Tag>> {
  final TagService _tagService = TagService();

  @override
  Future<List<Tag>> build() async {
    String? workspaceId = ref.watch(workspaceIdProvider);
    return workspaceId == null
        ? await _tagService.getAllPersonalTags()
        : await _tagService.getAllWorkspaceTags(workspaceId);
  }

  Future<void> _fetchData() async {
    final String? workspaceId = ref.watch(workspaceIdProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => workspaceId == null
        ? _tagService.getAllPersonalTags()
        : _tagService.getAllWorkspaceTags(workspaceId));
  }

  void _updateState(List<Tag> updatedTags) {
    state = AsyncValue.data(updatedTags);
  }

  Future<Tag?> createTag(TagDetail tagDetail) async {
    final String? workspaceId = ref.watch(workspaceIdProvider);
    final result = await AsyncValue.guard(() => workspaceId == null
        ? _tagService.createPersonalTag(tagDetail)
        : _tagService.createWorkspaceTag(
            workspaceId,
            tagDetail,
          ));

    return result.when(
      data: (tag) {
        if (tag != null) {
          _updateState([...(state.value ?? []), tag]);
          return tag;
        }
        return null;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<Tag?> updateTag(String id, TagDetail tagDetail) async {
    final updatedTag = await _tagService.updateTag(id, tagDetail);
    if (updatedTag != null) {
      state = AsyncValue.data(
          state.value!.map((d) => d.id == id ? updatedTag : d).toList());
      return updatedTag;
    }
    return null;
  }

  Future<void> removeTag(String id) async {
    final success = await _tagService.deleteTag(id);
    if (success) {
      state = AsyncValue.data(state.value!.where((d) => d.id != id).toList());
    }
  }

  Tag? getTag(String id) {
    try {
      return state.value?.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isExist(String name) => state.value?.any((e) => e.name == name) ?? false;
}
