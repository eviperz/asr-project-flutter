import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/authentication_page/sign_in_page.dart';
import 'package:asr_project/pages/diary_form_page/diary_form_page.dart';
import 'package:asr_project/pages/diary_search_page/diary_search_page.dart';
import 'package:asr_project/pages/event_page/event_page.dart';
import 'package:asr_project/pages/record_voice_page.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_detail_page.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_setting/workspace_setting_page.dart';
import 'package:asr_project/pages/workspace_page/workspace_invitation_page/workspace_invitation.dart';
import 'package:asr_project/pages/workspace_page/workspace_page/workspace_page.dart';
import 'package:asr_project/providers/theme_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/custom_bottom_navbar.dart';
import 'package:asr_project/pages/home_page/home_page.dart';
import 'package:asr_project/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(themeProvider);
    return MaterialApp(
      title: "ASR App",
      theme: theme,
      home: SignInPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/signin":
            return MaterialPageRoute(builder: (context) => SignInPage());

          case "/home":
            return MaterialPageRoute(builder: (context) => HomePage());

          case "/workspace":
            return MaterialPageRoute(builder: (context) => WorkspacePage());

          case "/workspace/notification":
            return MaterialPageRoute(
                builder: (context) => WorkspaceInvitation());

          case "/workspace/detail":
            return MaterialPageRoute(
                builder: (context) =>
                    WorkspaceDetailPage());

          case "/workspace/setting":
            Workspace workspace = settings.arguments as Workspace;
            return MaterialPageRoute<Workspace>(
                builder: (context) =>
                    WorkspaceSettingPage(workspace: workspace));

          case "/diary/search":
            final List<Diary> diaries = settings.arguments as List<Diary>;
            return MaterialPageRoute(
              builder: (context) =>
                  DiarySearchPage(type: "personal", diaries: diaries),
            );

          case "/diary/detail":
            final Diary diary = settings.arguments as Diary;

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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  void _onChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspaceProvider);
    final User? user = ref.watch(userProvider).value;

    late int workspacePendingLength = 0;
    if (workspacesAsync.hasValue) {
      workspacePendingLength =
          ref.watch(workspaceProvider.notifier).workspacesPending.length;
    }

    final List<Widget> pages = [
      HomePage(),
      WorkspacePage(),
      EventPage(),
    ];

    return Scaffold(
      drawer: CustomDrawer(name: user?.name ?? "Guest"),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: badges.Badge(
              position: badges.BadgePosition.bottomEnd(bottom: -4, end: 0),
              badgeContent: Text(
                workspacePendingLength.toString(),
                style: TextStyle(color: Colors.white),
              ),
              showBadge: workspacePendingLength != 0,
              child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/workspace/notification");
                  },
                  icon: Icon(Icons.group_add)),
            ),
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onChange,
      ),
    );
  }
}
