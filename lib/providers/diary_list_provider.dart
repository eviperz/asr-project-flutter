import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diaryListProvider = StateNotifierProvider<DiaryListNotifier, List<Diary>>(
  (ref) => DiaryListNotifier(ref),
);

class DiaryListNotifier extends StateNotifier<List<Diary>> {
  Ref ref;

  DiaryListNotifier(this.ref) : super([]) {
    _fetchDiaries();
  }

  Future<void> _fetchDiaries() async {
    // TODO store and fetch from DB
  }

  Future<void> addDiaries(Iterable<Diary> diaryList) async {
    if (diaryList.isEmpty) return;
    state = List.unmodifiable([...state, ...diaryList]);
  }

  Future<void> addDiary(Diary diary) async {
    ref.read(tagListProvider.notifier).addTags(diary.tags);
    state = List.unmodifiable([...state, diary]);
  }

  Future<void> removeDiary(String id) async {
    state = List.unmodifiable(state.where((i) => i.id != id));
    ref.read(diaryFavoriteProvider.notifier).removeFavorite(id);
  }

  Future<void> removeDiaries(Iterable<String> ids) async {
    final List<Diary> removedDiaries =
        state.where((i) => ids.contains(i.id)).toList();
    final List<Tag> removedTags =
        removedDiaries.expand((diary) => diary.tags).toList();

    state = List.unmodifiable(state.where((i) => !ids.contains(i.id)));

    ref.read(diaryFavoriteProvider.notifier).removeFavorites(ids);

    ref.read(tagListProvider.notifier).removeTags(removedTags);
  }

  Future<void> updateDiary(DiaryDetail detail) async {
    if (isExist(detail.id)) {
      final List<Tag> diaryTags = get(detail.id).tags;

      final List<Tag> removeTags =
          diaryTags.where((tag) => !detail.tags!.contains(tag)).toList();
      ref.read(tagListProvider.notifier).removeTags(removeTags);

      final List<Tag> addTags =
          detail.tags!.where((tag) => !diaryTags.contains(tag)).toList();
      ref.read(tagListProvider.notifier).addTags(addTags);
    } else {
      addDiary(Diary.fromDetail(detail));
      return;
    }

    state = List.unmodifiable(state.map((diary) {
      return diary.id == detail.id ? diary.copyWith(detail) : diary;
    }).toList());
  }

  Diary get(String id) {
    return state.firstWhere((e) => e.id == id);
  }

  bool isExist(String id) {
    return state.any((e) => e.id == id);
  }

  Set<String> get tags {
    return Set.from(state.expand((e) => e.tags));
  }
}
