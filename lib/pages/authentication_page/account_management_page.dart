import 'dart:io';

import 'package:asr_project/models/user.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountManagementPage extends ConsumerStatefulWidget {
  const AccountManagementPage({super.key});
  @override
  ConsumerState<AccountManagementPage> createState() =>
      _AccountManagementPageState();
}

class _AccountManagementPageState extends ConsumerState<AccountManagementPage> {
  bool _isImageLoading = false;
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  Future<File?> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path ?? '');
      return file;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<User?> userAsync = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: userAsync.when(
            data: (user) {
              String name = user!.name;
              _nameTextEditingController.text = name;

              String email = user.email;
              _emailTextEditingController.text = email;

              final Image image = user.getProfile();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ProfileImage(
                            profile: image,
                            isLoading: _isImageLoading,
                            size: 100,
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton.filled(
                                onPressed: () async {
                                  File? file = await _pickImage();
                                  if (file != null) {
                                    setState(() {
                                      _isImageLoading = true;
                                    });
                                    await ref
                                        .read(userProvider.notifier)
                                        .updateUser(image: file);
                                    setState(() {
                                      _isImageLoading = false;
                                    });
                                  }
                                },
                                icon: Icon(Icons.edit)))
                      ],
                    ),
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(email),
                  SizedBox(
                    height: 32,
                  ),
                  Divider(),
                  AccountTextfield(
                      label: "Name",
                      hintText: "Enter Name",
                      controller: _nameTextEditingController,
                      onSubmit: (value) {
                        ref.read(userProvider.notifier).updateUser(name: value);
                      }),
                  Divider(),
                  AccountTextfield(
                      label: "Email",
                      hintText: "Enter Email",
                      controller: _emailTextEditingController),
                ],
              );
            },
            error: (error, stack) => Center(child: Text('Error: $error')),
            loading: () => Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )),
    );
  }
}

class AccountTextfield extends StatefulWidget {
  const AccountTextfield({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.onSubmit,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final Function(String)? onSubmit;

  @override
  State<AccountTextfield> createState() => _AccountTextfieldState();
}

class _AccountTextfieldState extends State<AccountTextfield> {
  late String _data;
  late bool _isEdit = false;

  @override
  void initState() {
    _data = widget.controller.text.trim();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
      child: ListTile(
        title: Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Theme.of(context).colorScheme.tertiary),
        ),
        subtitle: !_isEdit
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _data,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.onSubmit != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEdit = true;
                          });
                        },
                        child: Text("edit"),
                      )
                  ],
                ),
              )
            : Column(
                children: [
                  CustomTextfield(
                    hintText: widget.hintText,
                    keyboardType: TextInputType.text,
                    textEditController: widget.controller,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEdit = false;
                          });
                          widget.controller.text = _data;
                        },
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEdit = false;
                              _data = widget.controller.text;
                            });

                            if (widget.onSubmit != null) {
                              widget.onSubmit!(widget.controller.text.trim());
                            }
                          },
                          child: Text("Confirm")),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
