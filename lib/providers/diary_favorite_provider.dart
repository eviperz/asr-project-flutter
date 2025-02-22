import 'package:flutter_riverpod/flutter_riverpod.dart';

final diaryFavoriteProvider =
    StateNotifierProvider<DiaryFavoriteNotifier, Set<String>>(
  (ref) => DiaryFavoriteNotifier(),
);

class DiaryFavoriteNotifier extends StateNotifier<Set<String>> {
  DiaryFavoriteNotifier() : super(Set<String>.unmodifiable({}));

  void addFavorite(String id) {
    if (state.contains(id)) return;
    state = Set.unmodifiable({...state, id});
  }

  void addFavorites(Iterable<String> ids) {
    if (state.containsAll(ids)) return;
    state = Set.unmodifiable({...state, ...ids});
  }

  void removeFavorite(String id) {
    if (!state.contains(id)) return;
    state = Set.unmodifiable(
        state.where((e) => e != id));
  }

  void removeFavorites(Iterable<String> ids) {
    if (!state.any((e) => ids.contains(e))) return;
    state = Set.unmodifiable(state.where((e) => !ids.contains(e)));
  }

  void toggleFavorite(id) {
    if (state.contains(id)) {
      removeFavorite(id);
    } else {
      addFavorite(id);
    }
  }

  bool isFavorite(String id) {
    return state.contains(id);
  }
}
