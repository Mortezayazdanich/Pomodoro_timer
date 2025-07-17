import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/pomodoro_session.dart';

class DatabaseService {
  static const String _projectsBoxName = 'projects';
  static const String _sessionsBoxName = 'sessions';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(PomodoroSessionAdapter());
    Hive.registerAdapter(SessionTypeAdapter());
    
    // Open boxes
    await Hive.openBox<Project>(_projectsBoxName);
    await Hive.openBox<PomodoroSession>(_sessionsBoxName);
  }

  static Box<Project> get projectsBox => Hive.box<Project>(_projectsBoxName);
  static Box<PomodoroSession> get sessionsBox => Hive.box<PomodoroSession>(_sessionsBoxName);

  // Project operations
  static Future<void> saveProject(Project project) async {
    await projectsBox.put(project.id, project);
  }

  static Future<void> deleteProject(String id) async {
    await projectsBox.delete(id);
  }

  static List<Project> getAllProjects() {
    return projectsBox.values.toList();
  }

  static Project? getProject(String id) {
    return projectsBox.get(id);
  }

  // Session operations
  static Future<void> saveSession(PomodoroSession session) async {
    await sessionsBox.put(session.id, session);
  }

  static Future<void> deleteSession(String id) async {
    await sessionsBox.delete(id);
  }

  static List<PomodoroSession> getAllSessions() {
    return sessionsBox.values.toList();
  }

  static List<PomodoroSession> getSessionsForProject(String projectId) {
    return sessionsBox.values
        .where((session) => session.projectId == projectId)
        .toList();
  }

  static List<PomodoroSession> getSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return sessionsBox.values
        .where((session) => 
            session.startTime.isAfter(startOfDay) && 
            session.startTime.isBefore(endOfDay))
        .toList();
  }

  static List<PomodoroSession> getTodaysSessions() {
    return getSessionsForDate(DateTime.now());
  }

  static Future<void> dispose() async {
    await Hive.close();
  }
}
