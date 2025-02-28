import 'package:asr_project/models/tag.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Diary {
  final String id;
  final String _title;
  final Delta content;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Diary({
    String? id,
    String? title,
    Delta? content,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? Uuid().v4(),
        _title = title ?? '',
        content = content ?? Delta()
          ..insert('\n'),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get title => _title.isEmpty ? 'Untitled' : _title;

  String get formatDate {
    return DateFormat("dd MMM yyyy").format(updatedAt);
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
        id: map['id'],
        title: map['title'],
        content: Delta.fromJson(map['content']),
        tags: (map['tags'] as List)
            .map((tag) => Tag.fromMap(tag as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']));
  }

  @override
  bool operator ==(Object other) {
    if (other is! Diary) return false;
    return id == other.id &&
        title == other.title &&
        content == other.content &&
        tags == other.tags &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, content, tags, createdAt, updatedAt);
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
