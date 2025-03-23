import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
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
  DateTime? selectedDay = DateTime.now();

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
    final AsyncValue diaryFoldersAsync = ref.watch(diaryFoldersProvider);
    final List<Diary> diaries = [];
    if (diaryFoldersAsync.hasValue) {
      diaries
          .addAll(ref.watch(diaryFoldersProvider.notifier).allDiariesInFolders);
    }

    final List<Diary> diariesForSelectedDay = diaries.where((diary) {
      // Compare diary's createdAt date with the selected day
      if (selectedDay != null) {
        return diary.createdAt.year == selectedDay?.year &&
            diary.createdAt.month == selectedDay?.month &&
            diary.createdAt.day == selectedDay?.day;
      }
      return false;
    }).toList();

    // Log the diaries for debugging
    log("Diaries for selected day: ${diariesForSelectedDay.length}");

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Calendar',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Center(
              child: SizedBox(
                width: 340,
                height: 320,
                child: TableCalendar(
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
                  rowHeight: 40,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha((0.3 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((0.3 * 255).toInt()),
              thickness: 1.5,
            ),
            SizedBox(height: 20),
            Text(
              '${selectedDay?.day ?? 0} ${monthNames[(selectedDay?.month ?? 1) - 1]} ${selectedDay?.year ?? 0}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 32.0),
              child: Divider(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((0.1 * 255).toInt()),
              ),
            ),
            if (diariesForSelectedDay.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: diariesForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final Diary diary = diariesForSelectedDay[index];
                    return DiaryListTile(canEdit: true, diary: diary);
                  },
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Divider(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
              )
            else
              // If no diaries for the selected day, show a message
              Expanded(
                child: Center(
                  child: Text(
                    selectedDay != null
                        ? 'No diaries for ${selectedDay!.day} ${monthNames[selectedDay!.month - 1]} ${selectedDay!.year}'
                        : 'Please select a day',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
