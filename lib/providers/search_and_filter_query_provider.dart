import 'package:flutter_riverpod/flutter_riverpod.dart';

// search
final searchQueryProvider = StateProvider.autoDispose((ref) => "");

// filter?
final filterQueryProvider = StateProvider.autoDispose<bool>((ref) => false);

// filter sort
final sortByDateTimeFilterQueryProvider =
    StateNotifierProvider.autoDispose<SortNotifier, bool>(
        (ref) => SortNotifier(true));

class SortNotifier extends StateNotifier<bool> {
  SortNotifier(super.state);

  void toggleSort() {
    state = !state;
  }

  void clear() {
    state = true;
  }
}

// filter tags
final selectedTagsProvider =
    StateNotifierProvider.autoDispose<SelectedTagsNotifier, Set<String>>(
  (ref) => SelectedTagsNotifier({}),
);

class SelectedTagsNotifier extends StateNotifier<Set<String>> {
  SelectedTagsNotifier(super.state);

  void setTags(Set<String> newTags) {
    state = newTags;
  }

  void clear() {
    state = {};
  }
}
