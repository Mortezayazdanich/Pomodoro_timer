import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String color;

  @HiveField(3)
  DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'Project(id: $id, name: $name, color: $color, createdAt: $createdAt)';
  }
}
