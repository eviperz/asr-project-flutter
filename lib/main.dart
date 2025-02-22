import 'package:asr_project/core/theme.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/pages/diary_overview_page/diary_overview_page.dart';
import 'package:asr_project/pages/diary_form_page/diary_form_page.dart';
import 'package:asr_project/pages/record_voice_page.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/custom_bottom_navbar.dart';
import 'package:asr_project/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryProvider = ref.read(diaryListProvider.notifier);

    return MaterialApp(
      title: "ASR App",
      theme: darkTheme,
      home: MainScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/dashboard":
            return MaterialPageRoute(builder: (context) => DashboardPage());

          case "/diary_overview":
            return MaterialPageRoute(
              builder: (context) => DiaryOverviewPage(),
            );

          case "/diary/create":
            Diary diary = Diary();
            return MaterialPageRoute(
              builder: (context) => DiaryFormPage(
                diary: diary,
              ),
            );

          case "/diary/detail":
            final String id = settings.arguments as String;
            Diary diary = diaryProvider.get(id);
            return MaterialPageRoute(
              builder: (context) => DiaryFormPage(diary: diary),
            );

          case "/record":
            return MaterialPageRoute(builder: (context) => RecordVoicePage());

          default:
            return MaterialPageRoute(builder: (context) => MainScreen());
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(),
      DiaryOverviewPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onChange,
      ),
    );
  }
}
