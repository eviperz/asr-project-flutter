import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/widgets/color_palette_selector.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:asr_project/widgets/default_modal.dart';

class TagEditModal extends ConsumerStatefulWidget {
  final Tag tag;

  const TagEditModal({super.key, required this.tag});

  @override
  ConsumerState<TagEditModal> createState() => _TagEditModalState();
}

class _TagEditModalState extends ConsumerState<TagEditModal> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late ColorPalette _currentColor;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
    _textEditingController.text = widget.tag.name;
    _currentColor = widget.tag.colorEnum;
  }

  String? _validateName() {
    if (_textEditingController.text.trim().isEmpty) {
      return "Tag name is required";
    }
    return null;
  }

  void _reloadColor(ColorPalette colorEnum) {
    setState(() {
      _currentColor = colorEnum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultModal(
      title: "Edit Tag",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Chip(
              label: Text(
                _textEditingController.text.trim(),
                style: TextStyle(fontSize: 20),
              ),
              backgroundColor: _currentColor.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextfield(
                label: "Tag",
                hintText: "Enter name",
                keyboardType: TextInputType.text,
                textEditController: _textEditingController,
                focusNode: _focusNode,
                errorText: _validateName()),
          ),
          ColorPaletteSelector(colorEnum: _currentColor, reload: _reloadColor),
          TextButton(
            onPressed: () {
              if (_validateName() == null) {
                ref.read(tagsProvider.notifier).updateTag(
                      widget.tag.id,
                      TagDetail(
                        name: _textEditingController.text,
                        colorEnum: _currentColor,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
