import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Diary {
  final String id;
  final String title;
  final Delta content;
  final Set<String> tags;
  final DateTime dateTime;

  Diary({
    String? id,
    String? title,
    Delta? content,
    Set<String>? tags,
    DateTime? dateTime,
  })  : id = id ?? Uuid().v4(),
        title = title ?? '',
        content = content ?? Delta()
          ..insert('\n'),
        tags = tags ?? {},
        dateTime = dateTime ?? DateTime.now();

  String getFormatDate() {
    return DateFormat("dd MMM yyyy").format(dateTime);
  }

  Diary copyWith(DiaryDetail detail) {
    return Diary(
      id: id,
      title: detail.title ?? title,
      content: detail.content ?? content,
      tags: detail.tags ?? tags,
      dateTime: detail.dateTime ?? dateTime,
    );
  }

  // Updated toMap method with isFavorite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': jsonEncode(tags.toList()),
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Diary.fromDetail(DiaryDetail detail) {
    return Diary(
      id: detail.id,
      title: detail.title,
      content: detail.content,
      tags: detail.tags,
      dateTime: detail.dateTime,
    );
  }

  // Updated fromMap method with isFavorite
  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tags: Set<String>.from(jsonDecode(map['tags'])),
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Diary) return false;
    return id == other.id &&
        title == other.title &&
        content == other.content &&
        tags == other.tags &&
        dateTime == other.dateTime;
  }

  @override
  int get hashCode => Object.hash(id, title, content, tags, dateTime);
}

class DiaryDetail {
  final String id;
  final String? title;
  final Delta? content;
  final Set<String>? tags;
  final DateTime? dateTime;

  const DiaryDetail({
    required this.id,
    this.title,
    this.content,
    this.tags,
    this.dateTime,
  });
}
