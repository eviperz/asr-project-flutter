import 'package:asr_project/models/tag.dart';
import 'package:asr_project/services/tag_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier Provider
final tagListProvider = AsyncNotifierProvider<TagListNotifier, List<Tag>>(
  () => TagListNotifier(),
);

// Notifier Class
class TagListNotifier extends AsyncNotifier<List<Tag>> {
  late final TagService _tagService;

  @override
  Future<List<Tag>> build() async {
    _tagService = TagService();
    return await _tagService.fetchTags();
  }

  Future<void> loadTags() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _tagService.fetchTags());
  }

  Future<Tag?> addTag(TagDetail tagDetail) async {
    final tag = await _tagService.addTag(tagDetail);
    if (tag != null) {
      state = AsyncValue.data([...state.value ?? [], tag]);
      return tag;
    }
    return null;
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

  bool isExist(String id) => state.value?.any((e) => e.id == id) ?? false;
}
