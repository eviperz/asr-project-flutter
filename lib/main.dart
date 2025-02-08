import 'package:asr_project/core/theme.dart';
import 'package:asr_project/providers/navbar_state_provider.dart';
import 'package:asr_project/screens/diary_creation_screen.dart';
import 'package:asr_project/screens/diary_overview_screen.dart';
import 'package:asr_project/widgets/custom_bottom_navbar.dart';
import 'package:asr_project/screens/dashboard_screen.dart';
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
      routes: {
        "/dashboard": (context) => DashboardScreen(),
        "/all_diary": (context) => DiaryOverviewScreen(),
        "/diary/create": (context) => DiaryCreationScreen(),
      },
      theme: darkTheme,
      home: MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    final List<Widget> pages = [
      DashboardScreen(),
      DiaryOverviewScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
