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
    return await fetchData();
  }

  Future<List<Tag>> fetchData() async {
    state = AsyncLoading();
    final String? workspaceId = ref.read(workspaceIdProvider);
    List<Tag> tags;

    if (workspaceId == null) {
      tags = await _tagService.getAllPersonalTags();
    } else {
      tags = await _tagService.getAllWorkspaceTags(workspaceId);
    }

    state = AsyncData(tags);
    return tags;
  }

  Future<Tag?> createTag(TagDetail tagDetail) async {
    final String? workspaceId = ref.watch(workspaceIdProvider);
    try {
      final Tag? tag = workspaceId == null
          ? await _tagService.createPersonalTag(tagDetail)
          : await _tagService.createWorkspaceTag(
              workspaceId,
              tagDetail,
            );
      if (tag != null) {
        state = AsyncData([...(state.value ?? []), tag]);
        return tag;
      } else {
        return null;
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<Tag?> updateTag(String id, TagDetail tagDetail) async {
    try {
      final updatedTag = await _tagService.updateTag(id, tagDetail);
      if (updatedTag != null) {
        state = AsyncData((state.value ?? [])
            .map((d) => d.id == id ? updatedTag : d)
            .toList());
        return updatedTag;
      } else {
        return null;
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> removeTag(String id) async {
    try {
      final success = await _tagService.deleteTag(id);
      if (success) {
        state =
            AsyncData((state.value ?? []).where((d) => d.id != id).toList());
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
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
