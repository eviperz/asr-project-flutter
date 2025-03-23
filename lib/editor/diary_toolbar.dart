import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class DiaryToolbar extends StatefulWidget {
  final quill.QuillController controller;

  const DiaryToolbar({
    super.key,
    required this.controller,
  });

  @override
  State<DiaryToolbar> createState() => _DiaryToolbarState();
}

class _DiaryToolbarState extends State<DiaryToolbar> {
  // void _showAsrDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => ASRDialog(
  //       controller: widget.controller,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 10, right: 70),
        child: SizedBox(
          height: 50,
          child: quill.QuillSimpleToolbar(
            controller: widget.controller,
            configurations: quill.QuillSimpleToolbarConfigurations(
                // customButtons: [
                //   quill.QuillToolbarCustomButtonOptions(
                //     icon: const Icon(Icons.mic_external_on),
                //     onPressed: _showAsrDialog,
                //   ),
                // ],
                ),
          ),
        ),
      ),
    );
  }
}
