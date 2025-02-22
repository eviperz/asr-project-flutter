import 'package:uuid/uuid.dart';

class Tag {
  final String id;
  final String name;
  final String colorCode;

  Tag({
    String? id,
    required this.name,
    required this.colorCode,
  }) : id = id ?? Uuid().v4();
}
