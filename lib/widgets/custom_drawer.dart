import 'package:asr_project/providers/theme_provider.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomDrawer extends ConsumerWidget {
  final String name;

  const CustomDrawer({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Center(
              child: ListTile(
                leading: ProfileImage(
                  size: 50,
                ),
                title: Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text("Theme"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) => themeNotifier.toggleTheme(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Sign out"),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/signin");
            },
          ),
        ],
      ),
    );
  }
}
