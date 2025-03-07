import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Diary {
  final String id;
  final String _title;
  final Delta content;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final Map<String, Diary> _cache = {};

  Diary({
    String? id,
    String? title,
    Delta? content,
    List<String>? tagIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? Uuid().v4(),
        _title = title ?? '',
        content = content ?? Delta()
          ..insert('\n'),
        tagIds = tagIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get title => _title.isEmpty ? 'Untitled' : _title;

  String get formatDate {
    return DateFormat("dd MMM yyyy").format(updatedAt);
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    if (_cache.containsKey(map['diaryId'])) {
      Diary cachedDiary = _cache[map['diaryId']]!;

      if (cachedDiary.title == map['title'] &&
          cachedDiary.content == Delta.fromJson(map['content']) &&
          cachedDiary.tagIds ==
              (map['tagIds'] as List<dynamic>).cast<String>()) {
        return cachedDiary;
      }
    }

    Diary diary = Diary(
      id: map['diaryId'] as String,
      title: map['title'] as String,
      content: Delta.fromJson(map['content']),
      tagIds: (map['tagIds'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );

    _cache[map['diaryId']] = diary;

    return diary;
  }

  static void removeCache(String id) => _cache.remove(id);

  @override
  bool operator ==(Object other) {
    if (other is! Diary) return false;
    return id == other.id &&
        title == other.title &&
        content == other.content &&
        tagIds == other.tagIds &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, content, tagIds, createdAt, updatedAt);
}

class DiaryDetail {
  final String? title;
  final Delta? content;
  final List<String>? tagIds;

  DiaryDetail({
    String? title,
    Delta? content,
    List<String>? tagIds,
  })  : title = title ?? 'Untitled',
        content = content ?? Delta()
          ..insert('\n'),
        tagIds = tagIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content?.toJson(),
      "tagIds": tagIds,
    };
  }
}
