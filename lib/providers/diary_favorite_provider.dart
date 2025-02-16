import 'package:flutter_riverpod/flutter_riverpod.dart';

final diaryFavoriteProvider =
    StateNotifierProvider<DiaryFavoriteNotifier, Set<String>>(
  (ref) => DiaryFavoriteNotifier(),
);

class DiaryFavoriteNotifier extends StateNotifier<Set<String>> {
  DiaryFavoriteNotifier() : super(Set<String>.unmodifiable({}));

  // Add a diary to favorites
  void addFavorite(String id) {
    if (state.contains(id)) return;
    state = Set.unmodifiable({...state, id}); // Add the ID to the set
  }

  void addFavorites(Iterable<String> ids) {
    if (state.containsAll(ids)) return;
    state = Set.unmodifiable({...state, ...ids});
  }

  // Remove a diary from favorites
  void removeFavorite(String id) {
    if (!state.contains(id)) return;
    state = Set.unmodifiable(
        state.where((e) => e != id)); // Remove the ID from the set
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

  // Check if a diary is in favorites
  bool isFavorite(String id) {
    return state.contains(id);
  }
}
