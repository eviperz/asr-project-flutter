import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.tag.color;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultModal(
      title: "Edit Tag",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: ColorPicker(
              enableAlpha: false,
              labelTypes: [],
              hexInputBar: true,
              colorPickerWidth: 250,
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  currentColor = color;
                });
              },
            ),
          ),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                String hexColor = colorToHex(currentColor);
                ref.read(tagsProvider.notifier).updateTag(
                      widget.tag.id,
                      TagDetail(
                        name: widget.tag.name,
                        colorCode: hexColor,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
