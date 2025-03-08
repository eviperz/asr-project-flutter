import 'package:asr_project/models/diary.dart';

class DiaryFolderModel {
  final String id;
  final String name;
  final List<Diary>? diaries;

  DiaryFolderModel({required this.id, required this.name, List<Diary>? diaries})
      : diaries = diaries ?? [];

  factory DiaryFolderModel.fromJson(Map<String, dynamic> json) {
    return DiaryFolderModel(
      id: json['diaryFolderModel']['diaryFolderId'] as String,
      name: json['diaryFolderModel']['folderName'] as String,
      diaries: json.containsKey('diaries')
          ? (json['diaries'] as List<dynamic>)
              .map((item) => Diary.fromMap(item))
              .toList()
          : [],
    );
  }

  DiaryFolderModel copyWith({String? id, String? name, List<Diary>? diaries}) {
    return DiaryFolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      diaries: diaries ?? this.diaries,
    );
  }
}

class DiaryFolderDetail {
  final String? folderName;
  final List<String>? diaryIds;

  DiaryFolderDetail({this.folderName, this.diaryIds});

  Map<String, dynamic> toJson() {
    return {
      if (folderName != null) "folderName": folderName,
      if (diaryIds != null) "diaryIds": diaryIds,
    };
  }
}
