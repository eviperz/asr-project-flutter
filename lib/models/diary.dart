import 'package:intl/intl.dart';

class Diary {
  final String title;
  final String content;
  final List<String> tags;
  final DateTime dateTime;

  const Diary({
    required this.title,
    required this.content,
    required this.tags,
    required this.dateTime,
  });

  String getFormatDate() {
    return DateFormat("dd MMM yyyy").format(dateTime);
  }
}
