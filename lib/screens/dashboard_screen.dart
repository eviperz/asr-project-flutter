import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary_list_view_horizontal.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  List<Diary> diaryList = [
    Diary(
      title: "Diary 1",
      content: "Content of Diary 1",
      tags: ["text", "asr"],
      dateTime: DateTime.now(),
    ),
    Diary(
      title: "Diary 2",
      content: "Content of Diary 2",
      tags: [],
      dateTime: DateTime.now(),
    ),
    Diary(
      title: "Diary 3",
      content: "Content of Diary 3",
      tags: [],
      dateTime: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                      diaryList: diaryList,
                    ),
                    DiaryListViewHorizontal(
                      title: "Favorite",
                      diaryList: diaryList,
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
