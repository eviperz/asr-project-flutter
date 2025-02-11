import 'package:asr_project/providers/search_and_filter_query_provider.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary_list/diary_card.dart';
import 'package:asr_project/widgets/filter_widget/filter_menu_widget.dart';
import 'package:asr_project/widgets/filter_widget/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryOverviewScreen extends ConsumerWidget {
  const DiaryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filterQuery = ref.watch(filterQueryProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final isSortByDateDescending = ref.watch(sortByDateTimeFilterQueryProvider);

    // diary
    final List<Diary> diaries = [
      Diary(
          title: 'Diary 1',
          content: 'Content 1',
          tags: ['text', 'asr'],
          dateTime: DateTime(2024, 12, 25)),
      Diary(
          title: 'Diary 2',
          content: 'Content 2',
          tags: ['flutter', 'dart'],
          dateTime: DateTime(2024, 11, 25)),
      Diary(
          title: 'Diary 3',
          content: 'Content 3',
          tags: ['text', 'flutter'],
          dateTime: DateTime(2024, 10, 25)),
    ];

    final filteredDiaries = diaries.where((diary) {
      bool matchesSearch = searchQuery.isEmpty ||
          diary.title.toLowerCase().contains(searchQuery.toLowerCase().trim());

      bool matchesTags = selectedTags.isEmpty ||
          diary.tags.any((tag) => selectedTags.contains(tag));

      return matchesSearch && matchesTags;
    }).toList();

    filteredDiaries.sort((a, b) {
      return isSortByDateDescending
          ? b.dateTime.compareTo(a.dateTime)
          : a.dateTime.compareTo(b.dateTime);
    });

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
                      onChanged: (value) =>
                          ref.read(searchQueryProvider.notifier).state = value,
                      decoration: const InputDecoration(
                        hintText: "Search by title",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  FilterWidget(),
                ],
              ),
              if (filterQuery == true) FilterMenuWidget(),
              if (filteredDiaries.isEmpty)
                const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDiaries.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: DiaryCard(
                          diary: filteredDiaries[index],
                          width: double.infinity,
                          height: 200,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
