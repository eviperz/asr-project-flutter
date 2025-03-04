import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_setting_page.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkspaceDetailPage extends StatefulWidget {
  final Workspace workspace;
  const WorkspaceDetailPage({super.key, required this.workspace});

  @override
  State<WorkspaceDetailPage> createState() => _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends State<WorkspaceDetailPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textEditingController;

  final List categories = [
    {
      "name": "Default",
      "diaries": [Diary(), Diary()],
    },
    {
      "name": "category 2",
      "diaries": [Diary(), Diary()],
    }
  ];

  bool _creatingFolderMode = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _addFolder() {
    categories.add({
      "name": "New Folder",
      "diaries": [],
    });

    setState(() {
      _creatingFolderMode = true;
    });
  }

  void _showSettingModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return WorkspaceSettingPage(workspace: widget.workspace);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workspace.name),
        actions: [
          IconButton(onPressed: _showSettingModal, icon: Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              spacing: 16.0,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    hintText: "Search Diary",
                  ),
                  controller: _textEditingController,
                  // onTap: () {
                  //   Navigator.pushNamed(context, route)
                  // },
                  // onChanged: _filterWorkspaces,
                ),
                Column(
                  children: [
                    // DiaryFolderBlocks(
                    //   folders: categories,
                    //   onCreateFolder: _addFolder,
                    //   creatingFolderMode: _creatingFolderMode,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
