import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/diary_widget/diary_list_view_horizontal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Diary> diaryList = ref.watch(diaryListProvider);
    Set<String> favoriteIds = ref.watch(diaryFavoriteProvider);

    // Recently Diaries
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    final recentDiaries = diaryList.where((e) {
      return e.dateTime.isAfter(sevenDaysAgo) && e.dateTime.isBefore(now);
    }).toList();

    // Favorite Diaries
    final favoriteDiaries =
        diaryList.where((e) => favoriteIds.contains(e.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Text(
                          "Dashboard",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          "Create your note by yourself",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    DiaryListViewHorizontal(
                      title: "Recently",
                      subtitle: "Before 7 days ~ now",
                      diaryList: recentDiaries,
                    ),
                    DiaryListViewHorizontal(
                      title: "Favorite",
                      diaryList: favoriteDiaries,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {Navigator.pushNamed(context, "/diary/create")},
        icon: Icon(Icons.add),
        label: Text("Diary"),
      ),
    );
  }
}
