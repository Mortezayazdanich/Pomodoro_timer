import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
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
    
    // Open boxes with enhanced error handling
    try {
      await Hive.openBox<Project>(_projectsBoxName);
      await Hive.openBox<PomodoroSession>(_sessionsBoxName);
    } catch (e) {
      print('Error opening Hive boxes: $e');
      
      // If opening fails due to corruption, try to clear the data directory and start fresh
      try {
        await Hive.close();
        await _clearCorruptedData();
        await Hive.openBox<Project>(_projectsBoxName);
        await Hive.openBox<PomodoroSession>(_sessionsBoxName);
        print('Successfully recovered from corrupted database');
      } catch (e2) {
        print('Error initializing database after recovery attempt: $e2');
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

  // Helper method to clear corrupted Hive data
  static Future<void> _clearCorruptedData() async {
    print('Attempting to clear corrupted Hive data...');
    
    // Delete the specific box files if they exist
    final boxNames = [_projectsBoxName, _sessionsBoxName];
    
    for (final boxName in boxNames) {
      try {
        // Try to delete the box if it exists
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).deleteFromDisk();
        }
      } catch (e) {
        print('Error deleting box $boxName: $e');
      }
    }
    
    // Alternative approach: manually find and delete Hive files
    try {
      // Look for Hive files in common locations
      final possibleDirs = [
        Directory('${Directory.systemTemp.path}/pomodoro_timer'),
        Directory('${Directory.current.path}/hive_boxes'),
        Directory('${Directory.current.path}/.dart_tool/hive'),
      ];
      
      for (final dir in possibleDirs) {
        if (await dir.exists()) {
          print('Found Hive directory: ${dir.path}');
          try {
            await dir.delete(recursive: true);
            print('Deleted directory: ${dir.path}');
          } catch (e) {
            print('Could not delete directory ${dir.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error during manual cleanup: $e');
    }
  }
}
