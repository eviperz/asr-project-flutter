import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;

  const HomeAppBar({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome back",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            username,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: ClipOval(
            child: Container(
              height: 50,
              width: 50,
              color: Theme.of(context).colorScheme.secondary,
              child: Image.asset(
                "assets/images/default-profile.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
      toolbarHeight: 100,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
