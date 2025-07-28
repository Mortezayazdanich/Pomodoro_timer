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

  @HiveField(6)
  int shortBreakDuration; // in seconds or minutes

  @HiveField(7)
  int longBreakDuration; // in seconds or minutes

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.timerDuration = 1500, // default 25 min
    this.sessionType = 'pomodoro',
    this.shortBreakDuration = 300, // default 5 min
    this.longBreakDuration = 900, // default 15 min
  });

  @override
  String toString() {
    return 'Project(id: $id, name: $name, color: $color, createdAt: $createdAt, timerDuration: $timerDuration, sessionType: $sessionType, shortBreakDuration: $shortBreakDuration, longBreakDuration: $longBreakDuration)';
  }

  factory Project.fromFields(List fields) {
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      color: fields[2] as String,
      createdAt: fields[3] as DateTime,
      timerDuration: fields[4] as int? ?? 1500,
      sessionType: fields[5] as String? ?? 'pomodoro',
      shortBreakDuration: fields[6] as int? ?? 300,
      longBreakDuration: fields[7] as int? ?? 900,
    );
  }
}
