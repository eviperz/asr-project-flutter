import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';
import 'package:asr_project/widgets/color_palette_selector.dart';
import 'package:asr_project/widgets/default_modal.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';

class WorkspaceIconSelector extends StatefulWidget {
  final WorkspaceIconEnum workspaceIconEnum;
  final ColorPalette workspaceIconColorEnum;

  const WorkspaceIconSelector({
    super.key,
    required this.workspaceIconEnum,
    required this.workspaceIconColorEnum,
  });

  @override
  State<WorkspaceIconSelector> createState() => _WorkspaceIconSelectorState();
}

class _WorkspaceIconSelectorState extends State<WorkspaceIconSelector> {
  late WorkspaceIconEnum _workspaceIconEnum;
  late ColorPalette _workspaceIconColorEnum;

  @override
  void initState() {
    super.initState();
    _workspaceIconEnum = widget.workspaceIconEnum;
    _workspaceIconColorEnum = widget.workspaceIconColorEnum;
  }

  void _reloadColor(ColorPalette colorEnum) {
    setState(() {
      _workspaceIconColorEnum = colorEnum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<WorkspaceIconEnum> iconEnums = WorkspaceIconEnum.values;

    return DefaultModal(
      title: "Select Icon",
      child: Center(
        child: Column(
          spacing: 16.0,
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: iconEnums.map((iconEnum) {
                bool isSelected = _workspaceIconEnum == iconEnum;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _workspaceIconEnum = iconEnum;
                    });
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WorkspaceIcon(
                          workspaceIconEnum: iconEnum,
                          colorEnum: _workspaceIconColorEnum,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Icon(
                              Icons.done,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            ColorPaletteSelector(
              colorEnum: widget.workspaceIconColorEnum,
              reload: _reloadColor,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'iconEnum': _workspaceIconEnum,
                  'colorEnum': _workspaceIconColorEnum,
                });
              },
              child: Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
