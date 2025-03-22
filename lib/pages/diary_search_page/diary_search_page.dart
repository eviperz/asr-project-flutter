import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/tag.dart';
import 'package:asr_project/pages/diary_search_page/filter_menu.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiarySearchPage extends ConsumerStatefulWidget {
  final bool canEdit;
  const DiarySearchPage({super.key, required this.canEdit});

  @override
  ConsumerState<DiarySearchPage> createState() => _DiarySearchPageState();
}

class _DiarySearchPageState extends ConsumerState<DiarySearchPage> {
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Diary> _filteredDiaries = [];
  late bool _openFilterMenu = false;
  late bool _isAscending = true;
  final Set<Tag> _activeTags = {};

  @override
  void initState() {
    super.initState();
    _searchTextEditingController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
    _searchFocusNode.dispose();
  }

  List<Diary> _filterAndSortDiaries() {
    List<Diary> filtered = _filteredDiaries.where((diary) {
      bool matchesSearch = _searchTextEditingController.text.isEmpty ||
          diary.title
              .toLowerCase()
              .contains(_searchTextEditingController.text.toLowerCase().trim());

      bool matchTagFilter = _activeTags.isNotEmpty
          ? _activeTags.any((tag) => diary.tagIds.contains(tag.id))
          : true;

      return matchesSearch && matchTagFilter;
    }).toList();

    filtered.sort((a, b) {
      return _isAscending
          ? a.updatedAt.compareTo(b.updatedAt)
          : b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }

  void _sort() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _updateFilterTags(Tag tag) {
    setState(() {
      if (_activeTags.contains(tag)) {
        _activeTags.remove(tag);
      } else {
        _activeTags.add(tag);
      }
    });
  }

  void _clearActiveTags() {
    setState(() {
      _activeTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue diaryFolders = ref.watch(diaryFoldersProvider);
    if (diaryFolders.hasValue) {
      _filteredDiaries.clear();
      _filteredDiaries
          .addAll(ref.watch(diaryFoldersProvider.notifier).allDiariesInFolders);
    }
    return Scaffold(
      appBar: AppBar(
        title: CustomTextfield(
          hintText: "Search",
          iconData: Icons.search,
          canClear: true,
          keyboardType: TextInputType.text,
          textEditController: _searchTextEditingController,
          focusNode: _searchFocusNode,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _openFilterMenu = !_openFilterMenu;
              });
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
        bottom: _openFilterMenu
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.0),
                child: FilterMenu(
                  onSort: _sort,
                  isAscending: _isAscending,
                  onSelectTags: _updateFilterTags,
                  clearActiveTags: _clearActiveTags,
                  activeTags: _activeTags,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _filterAndSortDiaries().isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: ListView.separated(
                        itemCount: _filterAndSortDiaries().length,
                        itemBuilder: (context, index) {
                          final Diary diary = _filterAndSortDiaries()[index];
                          return DiaryListTile(
                              canEdit: widget.canEdit, diary: diary);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
