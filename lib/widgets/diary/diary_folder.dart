import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

class DiaryFolder extends StatefulWidget {
  final String type;
  final DiaryFolderModel folder;
  final List<DiaryFolderModel> folders;
  final List<Diary> diaries;
  final FocusNode? focusNode;
  final Function onUpdateFolderName;
  final Function onCreateDiary;
  final Function onDeleteFolder;

  const DiaryFolder({
    super.key,
    required this.type,
    required this.folder,
    required this.folders,
    required this.diaries,
    this.focusNode,
    required this.onUpdateFolderName,
    required this.onCreateDiary,
    required this.onDeleteFolder,
  });

  @override
  State<DiaryFolder> createState() => _DiaryFolderState();
}

class _DiaryFolderState extends State<DiaryFolder> {
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;
  late bool _isOpen;

  @override
  void initState() {
    _isOpen = false;

    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.focusNode != null) {
      _focusNode.requestFocus();
      log(_focusNode.hasFocus.toString());
    }

    _focusNode.addListener(() {
      setState(() {});
    });

    _textEditingController = TextEditingController();
    _textEditingController.text = widget.folder.name;

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  String _generateUniqueFolderName(String baseName, double count) {
    List<DiaryFolderModel> diaryFolders = widget.folders;

    String newName = count == 0 ? baseName : "$baseName (${count.toInt()})";

    bool isDuplicate = diaryFolders.any((folder) =>
        folder.name == newName && folder.name != widget.folder.name);

    if (isDuplicate) {
      return _generateUniqueFolderName(baseName, count + 1);
    }

    return newName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          leading: _isOpen
              ? Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).primaryColor,
                )
              : Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Theme.of(context).primaryColor,
                ),
          title: Row(
            spacing: 8.0,
            children: [
              Icon(Icons.folder),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Folder Name",
                  ),
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  onSubmitted: (value) {
                    String uniqueName =
                        _generateUniqueFolderName(value.trim(), 0);
                    _textEditingController.text = uniqueName;
                    widget.onUpdateFolderName(widget.folder.id, uniqueName);
                  },
                  onTapOutside: (event) {
                    String uniqueName = _generateUniqueFolderName(
                        _textEditingController.text.trim(), 0);
                    _textEditingController.text = uniqueName;
                    widget.onUpdateFolderName(widget.folder.id, uniqueName);
                    _focusNode.unfocus();
                  },
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              switch (value) {
                case "add":
                  widget.onCreateDiary(widget.folder.id);

                case "delete":
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      title: "Delete",
                      content: "Are you confirm for delete?",
                      onConfirm: () async {
                        try {
                          widget.onDeleteFolder(widget.folder.id);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Delete Folder!")),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Error delete diary folder: $e")),
                          );
                        }
                      },
                      onCancel: () => Navigator.pop(context),
                    ),
                  );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add',
                child: ListTile(
                  leading: Icon(Icons.note),
                  title: Text('Add Diary'),
                ),
              ),
              if (widget.folder.name != "Default")
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete Folder'),
                  ),
                ),
            ],
            padding: EdgeInsets.all(0),
            menuPadding: EdgeInsets.all(8.0),
          ),
        ),
        if (_isOpen)
          ListView.separated(
            shrinkWrap: true,
            itemCount: widget.diaries.length,
            itemBuilder: (context, index) {
              final Diary diary = widget.diaries[index];
              return ListTile(
                contentPadding: EdgeInsets.only(left: 90.0),
                leading: Icon(Icons.note),
                title: Text(diary.title),
                onTap: () {
                  Navigator.pushNamed(context, "/diary/detail", arguments: {
                    "type": widget.type,
                    "diary": diary,
                  });
                },
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Divider(),
              );
            },
          )
      ],
    );
  }
}
