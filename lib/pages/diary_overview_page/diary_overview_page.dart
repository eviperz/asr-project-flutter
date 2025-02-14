// import 'package:asr_project/providers/search_and_filter_query_provider.dart';
// import 'package:asr_project/models/diary.dart';
// import 'package:asr_project/services/diary_database.dart';
// import 'package:asr_project/widgets/diary_widget/diary_card.dart';
// import 'package:asr_project/widgets/filter_widget/filter_menu_widget.dart';
// import 'package:asr_project/widgets/filter_widget/filter_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class DiaryOverviewScreen extends ConsumerWidget {
//   const DiaryOverviewScreen({super.key});

//   Future<List<Diary>> _fetchDiaries() async {
//     final DiaryDatabase diaryDatabase = DiaryDatabase();
//     return await diaryDatabase.getDiaries(); // Fetch diaries asynchronously
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final searchQuery = ref.watch(searchQueryProvider);
//     final filterQuery = ref.watch(filterQueryProvider);
//     final selectedTags = ref.watch(selectedTagsProvider);
//     final isSortByDateDescending = ref.watch(sortByDateTimeFilterQueryProvider);

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             spacing: 10,
//             children: [
//               Row(
//                 spacing: 10,
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       onChanged: (value) =>
//                           ref.read(searchQueryProvider.notifier).state = value,
//                       decoration: const InputDecoration(
//                         hintText: "Search by title",
//                         hintStyle: TextStyle(color: Colors.grey),
//                         prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                   FilterWidget(),
//                 ],
//               ),
//               if (filterQuery == true) FilterMenuWidget(),
//               FutureBuilder<List<Diary>>(
//                 future: _fetchDiaries(), // Fetch diaries asynchronously
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Expanded(
//                       child: const Center(
//                         child: Text(
//                           "No results found",
//                           style: TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                       ),
//                     );
//                   } else {
//                     final List<Diary> diaries = snapshot.data!;

//                     // Apply search and filter logic here
//                     final filteredDiaries = diaries.where((diary) {
//                       bool matchesSearch = searchQuery.isEmpty ||
//                           diary.title
//                               .toLowerCase()
//                               .contains(searchQuery.toLowerCase().trim());

//                       bool matchesTags = selectedTags.isEmpty ||
//                           diary.tags.any((tag) => selectedTags.contains(tag));

//                       return matchesSearch && matchesTags;
//                     }).toList();

//                     // Sort the filtered diaries
//                     filteredDiaries.sort((a, b) {
//                       return isSortByDateDescending
//                           ? b.dateTime.compareTo(a.dateTime)
//                           : a.dateTime.compareTo(b.dateTime);
//                     });

//                     return Expanded(
//                       child: ListView.builder(
//                         itemCount: filteredDiaries.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 1.0),
//                             child: DiaryCard(
//                               diary: filteredDiaries[index],
//                               width: double.infinity,
//                               height: 200,
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
