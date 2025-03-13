import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';
import 'package:flutter/material.dart';

class WorkspaceIcon extends StatelessWidget {
  final WorkspaceIconEnum workspaceIconEnum;
  final ColorPalette colorEnum;
  final double? size;

  const WorkspaceIcon({
    super.key,
    required this.workspaceIconEnum,
    required this.colorEnum,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: size ?? 55,
      height: size ?? 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: colorEnum.color,
      ),
      child: Icon(
        workspaceIconEnum.icon,
        color: Colors.white,
      ),
    );
  }
}
