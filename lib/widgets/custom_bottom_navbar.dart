import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.text_snippet), label: "All Diary"),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Workspace"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month), label: "Event")
      ],
    );
  }
}
