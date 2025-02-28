import 'package:asr_project/widgets/diary/diary_folder.dart';
import 'package:flutter/material.dart';

class DiaryFolderBlocks extends StatelessWidget {
  final List categories;
  final Function onCreateFolder;
  final bool creatingFolderMode;

  const DiaryFolderBlocks({
    super.key,
    required this.categories,
    required this.onCreateFolder,
    required this.creatingFolderMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "All Diaries",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
              onPressed: () {
                onCreateFolder();
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return DiaryFolder(
                category: category,
                focusNode: creatingFolderMode ? FocusNode() : null,
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        ),
      ],
    );
  }
}
