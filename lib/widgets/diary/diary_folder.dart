import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:asr_project/widgets/diary/diary_card.dart';
import 'package:flutter/material.dart';

class DiaryFolder extends StatefulWidget {
  final String type;
  final DiaryFolderModel folder;
  final List<Diary> diaries;
  final FocusNode? focusNode;
  final Function onUpdateFolderName;
  final Function onCreateDiary;
  final Function onDeleteFolder;

  const DiaryFolder({
    super.key,
    required this.type,
    required this.folder,
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
    }

    _focusNode.addListener(() {
      if (mounted) {
        if (_textEditingController.text != widget.folder.name) {
          if (_textEditingController.text.isEmpty) {
            _textEditingController.text = widget.folder.name;
          } else {
            //
          }
        }
      }
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
                  onTapOutside: (event) {
                    widget.onUpdateFolderName(
                        widget.folder.id, _textEditingController.text);
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
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.diaries.length,
                  itemBuilder: (context, index) {
                    final Diary diary = widget.diaries[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: DiaryCard(
                          type: widget.type, diary: diary, width: 100),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ],
            ),
          )
      ],
    );
  }
}
