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

  @HiveField(4)
  int timerDuration; // in seconds or minutes

  @HiveField(5)
  String sessionType; // e.g., 'pomodoro', 'short_break', etc.

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.timerDuration = 1500, // default 25 min
    this.sessionType = 'pomodoro',
  });

  @override
  String toString() {
    return 'Project(id: $id, name: $name, color: $color, createdAt: $createdAt, timerDuration: $timerDuration, sessionType: $sessionType)';
  }
}
