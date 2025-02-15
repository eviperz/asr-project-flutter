import 'package:flutter/material.dart';

class DiaryTagList extends StatefulWidget {
  final Set<String> tags;
  final Function(Set<String>)? onChanged;

  const DiaryTagList({
    super.key,
    required this.tags,
    this.onChanged,
  });
  @override
  State<DiaryTagList> createState() => _DiaryTagListState();
}

class _DiaryTagListState extends State<DiaryTagList> {
  void _removeTag(String tag) {
    Set<String> tags = Set.from(widget.tags);
    tags.remove(tag);
    widget.onChanged!(tags);
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    Set<String> tags = Set.from(widget.tags);
    tags.add(tag);
    widget.onChanged!(tags);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ...widget.tags.map(
          (tag) => Chip(
            label: Text(tag),
            backgroundColor: Colors.grey,
            onDeleted: widget.onChanged != null ? () => _removeTag(tag) : null,
          ),
        ),
        if (widget.onChanged != null)
          AddTagButton(
            onTagAdded: _addTag,
          ),
      ],
    );
  }
}

class AddTagButton extends StatefulWidget {
  final Function(String) onTagAdded;

  const AddTagButton({super.key, required this.onTagAdded});

  @override
  State<AddTagButton> createState() => _AddTagButtonState();
}

class _AddTagButtonState extends State<AddTagButton> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) _controller.clear();
    });
  }

  void _addTag() {
    final String value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onTagAdded(value);
    }
    _toggleEditing();
  }

  @override
  Widget build(BuildContext context) {
    return isEditing
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 130,
                height: 40,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Enter tag...",
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _toggleEditing();
                        _controller.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                      ),
                    ),
                  ),
                  maxLength: 20,
                  buildCounter: (context,
                      {required int currentLength,
                      required int? maxLength,
                      required bool isFocused}) {
                    return SizedBox.shrink(); // Hides counter
                  },
                  onSubmitted: (_) => _addTag(),
                ),
              ),
            ],
          )
        : OutlinedButton(
            onPressed: _toggleEditing,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 6.0),
                Text("Add Tag"),
              ],
            ),
          );
  }
}
