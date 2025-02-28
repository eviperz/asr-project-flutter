import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';

class WorkspaceSettingPage extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceSettingPage({
    super.key,
    required this.workspace,
  });

  @override
  State<WorkspaceSettingPage> createState() => _WorkspaceSettingPageState();
}

class _WorkspaceSettingPageState extends State<WorkspaceSettingPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.workspace.name;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Workspace Setting"),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                spacing: 32.0,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WorkspaceIcon(),
                            TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Change Icon",
                                ))
                          ],
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Workspace Name",
                          hintText: "Enter workspace name",
                          suffixIcon: _textEditingController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _textEditingController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Users",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.add))
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: ListView.separated(
                            itemCount: widget.workspace.users.length + 1,
                            itemBuilder: (context, index) {
                              final User user = [
                                widget.workspace.owner,
                                ...widget.workspace.users
                              ][index];
                              return ListTile(
                                leading: ProfileImage(),
                                title: Text(user.username),
                                subtitle: Text(index == 0 ? "Owner" : "User"),
                                trailing: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    index != 0 ? Icons.remove_circle : null,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            }),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    width: double.maxFinite,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Delete Workspace",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
