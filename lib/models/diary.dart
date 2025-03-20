import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';

class Diary {
  final String id;
  final String title;
  final Delta content;
  final List<String> tagIds;
  final User? owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final Map<String, Diary> _cache = {};

  Diary({
    required this.id,
    required this.title,
    Delta? content,
    required this.tagIds,
    this.owner,
    required this.createdAt,
    DateTime? updatedAt,
  })  : content = content ?? Delta(),
        updatedAt = updatedAt ?? createdAt;

  String get formatDate {
    return DateFormat("dd MMM yyyy").format(updatedAt);
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    if (_cache.containsKey(map['diaryId'])) {
      Diary cachedDiary = _cache[map['diaryId']]!;

      if (cachedDiary.updatedAt == DateTime.parse(map['updatedAt'])) {
        return cachedDiary;
      }
    }

    Diary diary = Diary(
      id: map['diaryId'] as String,
      title: map['title'] as String,
      content: Delta.fromJson(map['content']),
      owner: User.userFromCache(map['userId']),
      tagIds: (map['tagIds'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );

    _cache[map['diaryId']] = diary;

    return diary;
  }

  Diary copyWith({
    String? title,
    Delta? content,
    List<String>? tagIds,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tagIds: tagIds ?? this.tagIds,
      owner: owner,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
  final String? userId;

  DiaryDetail({
    this.title,
    this.content,
    this.tagIds,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) "title": title,
      if (content != null) "content": content?.toJson(),
      if (tagIds != null) "tagIds": tagIds,
      if (userId != null) "userId": userId,
    };
  }

  static DiaryDetail createDiary() {
    return DiaryDetail(
      title: 'Untitled',
      content: Delta()..insert("\n"),
      tagIds: [],
      userId: AppConfig.userId,
    );
  }
}
