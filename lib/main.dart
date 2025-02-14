import 'package:asr_project/core/theme.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/pages/diary_form_page/diary_form_page.dart';
import 'package:asr_project/providers/navbar_state_provider.dart';
import 'package:asr_project/pages/diary_detail_page/diary_detail_page.dart';
import 'package:asr_project/pages/record_voice_page.dart';
import 'package:asr_project/widgets/custom_bottom_navbar.dart';
import 'package:asr_project/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ASR App",
      theme: darkTheme,
      home: MainScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/dashboard":
            return MaterialPageRoute(builder: (context) => DashboardPage());

          // case "/diary_overview":
          //   return MaterialPageRoute(
          //     builder: (context) => DiaryOverviewScreen(),
          //   );

          case "/diary/create":
            Diary diary = Diary(title: '', tags: {});
            return MaterialPageRoute(
              builder: (context) => DiaryFormPage(
                diary: diary,
              ),
            );

          case "/diary/edit":
            final diary = settings.arguments as Diary;
            return MaterialPageRoute(
              builder: (context) => DiaryFormPage(diary: diary),
            );

          case "/diary/detail":
            final diary = settings.arguments as Diary;
            return MaterialPageRoute(
              builder: (context) => DiaryDetailScreen(diary: diary),
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

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    final List<Widget> pages = [
      DashboardPage(),
      // DiaryOverviewScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
