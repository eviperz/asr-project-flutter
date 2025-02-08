import 'package:asr_project/providers/navbar_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavBar extends ConsumerWidget {
  // final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    // required this.currentIndex,
    // required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => {ref.read(currentIndexProvider.notifier).state = index},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet), label: "All Diary"),
      ],
    );
  }
}
