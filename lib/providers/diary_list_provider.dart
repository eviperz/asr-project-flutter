import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
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
    // final fetchedDiaries = await fetch()
    // state = List.unmodifiable(fetchedDiaries);
  }

  Future<void> addDiaries(Iterable<Diary> diaryList) async {
    if (diaryList.isEmpty) return;
    state = List.unmodifiable([...state, ...diaryList]);
  }

  Future<void> addDiary(Diary diary) async {
    state = List.unmodifiable([...state, diary]);
  }

  Future<void> removeDiary(String id) async {
    state = List.unmodifiable(state.where((i) => i.id != id));
    ref.read(diaryFavoriteProvider.notifier).removeFavorite(id);
  }

  Future<void> removeDiaries(Iterable<String> ids) async {
    state = List.unmodifiable(state.where((i) => !ids.contains(i.id)));
    ref.read(diaryFavoriteProvider.notifier).removeFavorites(ids);
  }

  Future<void> updateDiary(DiaryDetail detail) async {
    if (!isExist(detail.id)) {
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
