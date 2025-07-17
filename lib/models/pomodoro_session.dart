import 'package:hive/hive.dart';

part 'pomodoro_session.g.dart';

@HiveType(typeId: 1)
class PomodoroSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  int duration; // in minutes

  @HiveField(5)
  SessionType type;

  @HiveField(6)
  bool completed;

  PomodoroSession({
    required this.id,
    required this.projectId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.type,
    required this.completed,
  });

  @override
  String toString() {
    return 'PomodoroSession(id: $id, projectId: $projectId, startTime: $startTime, endTime: $endTime, duration: $duration, type: $type, completed: $completed)';
  }
}

@HiveType(typeId: 2)
enum SessionType {
  @HiveField(0)
  work,
  @HiveField(1)
  shortBreak,
  @HiveField(2)
  longBreak,
}
