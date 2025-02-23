import 'package:asr_project/models/diary.dart';
import 'package:asr_project/pages/home_page/categories_widget.dart';
import 'package:asr_project/pages/home_page/home_app_bar.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/diary_widget/diary_list_view_horizontal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Diary> diaryList = ref.watch(diaryListProvider);
    Set<String> favoriteIds = ref.watch(diaryFavoriteProvider);

    // Recently Diaries
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    final List<Diary> recentDiaries = diaryList.where((e) {
      return e.dateTime.isAfter(sevenDaysAgo) && e.dateTime.isBefore(now);
    }).toList();

    // Favorite Diaries
    final List<Diary> favoriteDiaries =
        diaryList.where((e) => favoriteIds.contains(e.id)).toList();

    // Categories
    final categories = [
      {
        "name": "Default",
        "diaries": diaryList,
      }
    ];

    return Scaffold(
      appBar: HomeAppBar(
        username: "Username",
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              if (recentDiaries.isNotEmpty)
                DiaryListViewHorizontal(
                  title: "Recently",
                  diaryList: recentDiaries,
                ),
              // if (favoriteDiaries.isNotEmpty)
              //   DiaryListViewHorizontal(
              //       title: "Favorite", diaryList: favoriteDiaries),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    Text(
                      "Categoires",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ...categories.map((category) {
                      return CategoriesWidget(
                        name: category["name"] as String,
                        diaries: category["diaries"] as List<Diary>,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {Navigator.pushNamed(context, "/diary/create")},
        icon: Icon(Icons.add),
        label: Text("Diary"),
      ),
    );
  }
}
