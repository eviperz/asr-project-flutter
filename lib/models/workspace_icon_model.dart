import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';

class WorkspaceIconModel {
  final WorkspaceIconEnum iconEnum;
  final ColorPalette colorEnum;

  WorkspaceIconModel({required this.iconEnum, required this.colorEnum});

  factory WorkspaceIconModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceIconModel(
      iconEnum: WorkspaceIconEnum.fromName(json['name']),
      colorEnum: ColorPalette.fromHex(json['colorCode']),
    );
  }
}

class WorkspaceIconDetail {
  final WorkspaceIconEnum? iconEnum;
  final ColorPalette? colorEnum;

  WorkspaceIconDetail({this.iconEnum, this.colorEnum});

  Map<String, dynamic> toJson() {
    return {
      if (iconEnum != null) "name": iconEnum?.name,
      if (colorEnum != null) "colorCode": colorEnum?.hexCode,
    };
  }
}
