import 'package:asr_project/pages/diary_overview_page/filter_button.dart';
import 'package:asr_project/pages/diary_overview_page/filter_menu.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/diary_widget/diary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryOverviewPage extends ConsumerStatefulWidget {
  const DiaryOverviewPage({super.key});

  @override
  ConsumerState<DiaryOverviewPage> createState() => _DiaryOverviewPageState();
}

class _DiaryOverviewPageState extends ConsumerState<DiaryOverviewPage> {
  String _searchQuery = '';
  bool _isFiltering = false;
  Set<String> _selectedTags = {};
  bool _isAscending = true;

  void _onFilter(bool value) {
    setState(() {
      _isFiltering = value;
    });
  }

  void _onSelectTags(Set<String> value) {
    setState(() {
      _selectedTags = value;
    });
  }

  void _onSort(bool value) {
    setState(() {
      _isAscending = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diaries = ref.watch(diaryListProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search by title",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  FilterButton(
                    onFilter: _onFilter,
                    isFiltering: _isFiltering,
                  ),
                ],
              ),
              if (_isFiltering == true)
                FilterMenu(
                  onSort: _onSort,
                  isAscending: _isAscending,
                  onSelectTags: _onSelectTags,
                  selectedTags: _selectedTags,
                ),
              Builder(
                builder: (context) {
                  if (diaries.isEmpty) {
                    return Expanded(
                      child: const Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  } else {
                    // Apply search and filter logic here
                    final filteredDiaries = diaries.where((diary) {
                      bool matchesSearch = _searchQuery.isEmpty ||
                          diary.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase().trim());

                      bool matchesTags = _selectedTags.isEmpty ||
                          diary.tags.any((tag) => _selectedTags.contains(tag));

                      return matchesSearch && matchesTags;
                    }).toList();

                    // Sort the filtered diaries
                    filteredDiaries.sort((a, b) {
                      return _isAscending
                          ? a.dateTime.compareTo(b.dateTime)
                          : b.dateTime.compareTo(a.dateTime);
                    });

                    return Expanded(
                      child: ListView.builder(
                        itemCount: filteredDiaries.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: DiaryCard(
                              diary: filteredDiaries[index],
                              width: double.infinity,
                              // height: 200,
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
