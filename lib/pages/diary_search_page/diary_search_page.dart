import 'package:asr_project/models/diary.dart';
import 'package:asr_project/pages/diary_search_page/filter_menu.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_list_tile.dart';
import 'package:flutter/material.dart';

class DiarySearchPage extends StatefulWidget {
  final String type;
  final List<Diary> diaries;
  const DiarySearchPage({super.key, required this.type, required this.diaries});

  @override
  State<DiarySearchPage> createState() => _DiarySearchPageState();
}

class _DiarySearchPageState extends State<DiarySearchPage> {
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Diary> _filteredDiaries = [];
  late bool _openFilterMenu = false;
  late bool _isAscending = true;
  final Set<String> _activeTags = {};

  @override
  void initState() {
    super.initState();
    _searchTextEditingController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));
    _searchFocusNode.requestFocus();
    _filteredDiaries.addAll(widget.diaries);
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
    _searchFocusNode.dispose();
  }

  List<Diary> _filterAndSortDiaries() {
    List<Diary> filtered = widget.diaries.where((diary) {
      bool matchesSearch = _searchTextEditingController.text.isEmpty ||
          diary.title
              .toLowerCase()
              .contains(_searchTextEditingController.text.toLowerCase().trim());

      return matchesSearch;
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

  void _updateFilterTags(String tagName) {
    setState(() {
      if (_activeTags.contains(tagName)) {
        _activeTags.remove(tagName);
      } else {
        _activeTags.add(tagName);
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
                          return DiaryListTile(diary: diary);
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
