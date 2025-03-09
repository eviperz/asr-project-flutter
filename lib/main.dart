import 'package:asr_project/core/theme.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/authentication_page/sign_in_page.dart';
import 'package:asr_project/pages/diary_form_page/diary_form_page.dart';
import 'package:asr_project/pages/event_page/event_page.dart';
import 'package:asr_project/pages/record_voice_page.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_detail_page.dart';
import 'package:asr_project/pages/workspace_page/workspace_page.dart';
import 'package:asr_project/widgets/custom_bottom_navbar.dart';
import 'package:asr_project/pages/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: "ASR App",
      theme: lightTheme,
      home: SignInPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/home":
            return MaterialPageRoute(builder: (context) => HomePage());

          case "/workspace":
            return MaterialPageRoute(builder: (context) => WorkspacePage());

          case "/workspace/detail":
            Workspace workspace = settings.arguments as Workspace;
            return MaterialPageRoute(
                builder: (context) =>
                    WorkspaceDetailPage(workspace: workspace));

          // case "/diary_overview":
          //   return MaterialPageRoute(
          //     builder: (context) => DiaryOverviewPage(),
          //   );

          case "/diary/detail":
            final Map<String, dynamic> args =
                settings.arguments as Map<String, dynamic>;
            final String type = args["type"];
            final Diary diary = args["diary"];

            return MaterialPageRoute(
              builder: (context) => DiaryFormPage(type: type, diary: diary),
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
      HomePage(),
      // DiaryOverviewPage(),
      WorkspacePage(),
      EventPage(),
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
