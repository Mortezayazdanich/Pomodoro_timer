import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/pomodoro_session.dart';

class DatabaseService {
  static const String _projectsBoxName = 'projects';
  static const String _sessionsBoxName = 'sessions';

  static Future<void> initialize() async {
    await Hive.initFlutter('pomodoro_timer');
    
    // Register adapters (only if not already registered)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PomodoroSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionTypeAdapter());
    }
    
    // Open boxes with error handling
    try {
      await Hive.openBox<Project>(_projectsBoxName);
      await Hive.openBox<PomodoroSession>(_sessionsBoxName);
    } catch (e) {
      // If opening fails, try to close any existing boxes and reopen
      try {
        await Hive.close();
        await Hive.openBox<Project>(_projectsBoxName);
        await Hive.openBox<PomodoroSession>(_sessionsBoxName);
      } catch (e2) {
        print('Error initializing database: $e2');
        rethrow;
      }
    }
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
