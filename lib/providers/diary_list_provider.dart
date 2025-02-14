import 'package:asr_project/models/diary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diaryListProvider = StateNotifierProvider<DiaryListNotifier, List<Diary>>(
  (ref) => DiaryListNotifier(),
);

class DiaryListNotifier extends StateNotifier<List<Diary>> {
  DiaryListNotifier() : super(List.unmodifiable([]));

  void addDiaries(Iterable<Diary> diaryList) {
    state = [...state, ...diaryList];
  }

  void addDiary(Diary diary) {
    state = [...state, diary];
  }

  void removeDiary(int index) {
    state = List.from(state)..removeAt(index);
  }

  void removeDiaries(Iterable<String> ids) {
    state = [...state.where((i) => !ids.contains(i.id))];
  }

  void updateDiary(DiaryDetail detail) {
    Diary diary;
    try {
      diary = state.firstWhere((i) => i.id == detail.id);
    } on StateError catch (_) {
      diary = Diary.fromDetail(detail);
    }
    state = [...state.where((i) => i.id != detail.id), diary.copyWith(detail)];
  }
}
