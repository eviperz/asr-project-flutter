import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/widgets/diary/diary_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class EventPage extends ConsumerStatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends ConsumerState<EventPage> {
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(diaryFoldersProvider.notifier).fetchData();
    });
  }

  // List of month names
  final List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final DateTime firstDay = DateTime(2020, 1, 1);
    final DateTime lastDay = DateTime(now.year, 12, 31);

    final DateTime focusedDay = now.isBefore(lastDay) ? now : lastDay;

    // Get the list of diaries from the provider
    final List<Diary> diaries =
        ref.watch(diaryFoldersProvider.notifier).allDiariesInFolders;

    final List<Diary> diariesForSelectedDay = diaries.where((diary) {
      // Compare diary's createdAt date with the selected day
      if (selectedDay != null && diary.createdAt != null) {
        return diary.createdAt!.year == selectedDay?.year &&
            diary.createdAt!.month == selectedDay?.month &&
            diary.createdAt!.day == selectedDay?.day;
      }
      return false;
    }).toList();

    // Log the diaries for debugging
    log("Diaries for selected day: ${diariesForSelectedDay.length}");

    return Scaffold(
      appBar: AppBar(title: Text('Event Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: focusedDay,
              firstDay: firstDay,
              lastDay: lastDay,
              selectedDayPredicate: (day) =>
                  selectedDay != null && isSameDay(selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected; // Update the selected day
                });
              },
            ),
            SizedBox(height: 20),
            Divider(color: Theme.of(context).colorScheme.primary, thickness: 2),
            SizedBox(height: 10),
            if (selectedDay != null)
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  '${selectedDay?.day ?? 0} ${monthNames[selectedDay?.month ?? 1 - 1]} ${selectedDay?.year ?? 0}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            if (diariesForSelectedDay.isNotEmpty)
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        diariesForSelectedDay.length,
                        (index) {
                          final diary = diariesForSelectedDay[index];
                          return DiaryListTile(diary: diary);
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              // If no diaries for the selected day, show a message
              Expanded(
                child: Text(
                  selectedDay != null
                      ? 'No diaries for ${selectedDay!.day} ${monthNames[selectedDay!.month - 1]} ${selectedDay!.year}'
                      : 'Please select a day',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
