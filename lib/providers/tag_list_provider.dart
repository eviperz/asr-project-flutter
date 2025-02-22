import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagListProvider = StateNotifierProvider<TagListNotifier, List<Tag>>(
  (ref) => TagListNotifier(ref),
);

class TagListNotifier extends StateNotifier<List<Tag>> {
  Ref ref;
  late Set<String> tagNameSet = {};

  TagListNotifier(this.ref) : super([]) {
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    // TODO store and fetch from DB
  }

  Future<void> addTags(List<Tag> tagList) async {
    for (Tag tag in tagList) {
      await addTag(tag);
    }
  }

  Future<void> addTag(Tag tag) async {
    if (!tagNameSet.contains(tag.name)) {
      tagNameSet.add(tag.name);
      state = List.unmodifiable([...state, tag]);
    }
  }

  Future<void> removeTags(List<Tag> tagList) async {
    for (Tag tag in tagList) {
      await removeTagUnused(tag);
    }
  }

  Future<void> removeTagUnused(Tag tag) async {
    final isUsed = ref.read(diaryListProvider).any(
          (diary) =>
              diary.tags.any((t) => t.name == tag.name && t.id != tag.id),
        );

    if (!isUsed) {
      state =
          List.unmodifiable(state.where((t) => t.name != tag.name).toList());
    }
  }
}
