import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/widgets/diary/diary_folder.dart';
import 'package:flutter/material.dart';

class DiaryFolderBlocks extends StatelessWidget {
  final List<DiaryFolderModel> folders;
  final Function onCreateFolder;
  final Function onUpdateFolderName;
  final Function onCreateDiary;
  final Function onDeleteFolder;
  final bool creatingFolderMode;

  const DiaryFolderBlocks({
    super.key,
    required this.folders,
    required this.onCreateFolder,
    required this.onUpdateFolderName,
    required this.onCreateDiary,
    required this.onDeleteFolder,
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
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final DiaryFolderModel folder = folders[index];
              final List<Diary> diaries = folder.diaries ?? [];
              final FocusNode focusNode = FocusNode();
              focusNode.requestFocus();
              return DiaryFolder(
                folder: folder,
                folders: folders,
                diaries: diaries,
                onUpdateFolderName: onUpdateFolderName,
                onCreateDiary: onCreateDiary,
                onDeleteFolder: onDeleteFolder,
                focusNode: creatingFolderMode ? focusNode : null,
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
