import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';

// Constants
const int defaultPomodoroMinutes = 25;
const int defaultShortBreakMinutes = 5;
const int defaultLongBreakMinutes = 15;

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', mode.toString());
}


class Settings {
  final int pomodoroMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  Settings({
    this.pomodoroMinutes = defaultPomodoroMinutes,
    this.shortBreakMinutes = defaultShortBreakMinutes,
    this.longBreakMinutes = defaultLongBreakMinutes,
  });

  Settings copyWith({
    int? pomodoroMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    return Settings(
      pomodoroMinutes: pomodoroMinutes ?? this.pomodoroMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    );
  }
}


class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  void updateSettings({
    int? pomodoroMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    state = state.copyWith(
      pomodoroMinutes: pomodoroMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
    );
  }
}

// Projects provider
final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super([]);

  void loadProjects() {
    state = DatabaseService.getAllProjects();
  }

  Future<void> addProject(String name, String color) async {
    final project = Project(
      id: const Uuid().v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService.saveProject(project);
    state = [...state, project];
  }

  Future<void> deleteProject(String id) async {
    await DatabaseService.deleteProject(id);
    state = state.where((project) => project.id != id).toList();
  }

  Future<void> updateProject(String id, String name, String color) async {
    final project = state.firstWhere((p) => p.id == id);
    project.name = name;
    project.color = color;
    
    await DatabaseService.saveProject(project);
    state = [...state];
  }
}

// Current project provider
final currentProjectProvider = StateProvider<Project?>((ref) => null);

// Timer state
enum TimerStatus { idle, running, paused, completed }

class TimerState {
  final TimerStatus status;
  final SessionType sessionType;
  final int remainingSeconds;
  final int totalSeconds;
  final int currentSession;
  final Project? currentProject;

  TimerState({
    this.status = TimerStatus.idle,
    this.sessionType = SessionType.work,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.currentSession = 1,
    this.currentProject,
  });

  TimerState copyWith({
    TimerStatus? status,
    SessionType? sessionType,
    int? remainingSeconds,
    int? totalSeconds,
    int? currentSession,
    Project? currentProject,
  }) {
    return TimerState(
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentSession: currentSession ?? this.currentSession,
      currentProject: currentProject ?? this.currentProject,
    );
  }

  double get progress => totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;
}

// Timer provider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier(this.ref) : super(TimerState());
  
  final Ref ref;
  Timer? _timer;
  DateTime? _sessionStartTime;

  void startTimer() {
    if (state.currentProject == null) return;
    
    _sessionStartTime = DateTime.now();
    state = state.copyWith(status: TimerStatus.running);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeSession();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resumeTimer() {
    startTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    _sessionStartTime = null;
    
    final settings = ref.read(settingsProvider);
    final seconds = _getSecondsForSessionType(state.sessionType, settings);
    
    state = state.copyWith(
      status: TimerStatus.idle,
      remainingSeconds: seconds,
      totalSeconds: seconds,
    );
  }

  void setProject(Project project) {
    // Update timer state
    state = state.copyWith(
      currentProject: project,
      sessionType: _mapSessionTypeString(project.sessionType),
      remainingSeconds: project.timerDuration,
      totalSeconds: project.timerDuration,
      currentSession: 1,
      status: TimerStatus.idle,
    );

    // Update global settings to match the selected project's timer config
    ref.read(settingsProvider.notifier).updateSettings(
      pomodoroMinutes: project.timerDuration ~/ 60, // convert seconds to minutes
      shortBreakMinutes: project.shortBreakDuration ~/ 60,
      longBreakMinutes: project.longBreakDuration ~/ 60,
    );
  }

  // Helper to map string to SessionType
  SessionType _mapSessionTypeString(String type) {
    switch (type) {
      case 'short_break':
        return SessionType.shortBreak;
      case 'long_break':
        return SessionType.longBreak;
      case 'pomodoro':
      default:
        return SessionType.work;
    }
  }

  Map<String, dynamic>? _getProjectSettings(String projectId) {
    // This is a stub function that should retrieve stored settings for a project.
    // Replace with actual code to fetch from a database or similar storage.
    return null;
  }

  Future<void> saveProjectSettings(String projectId, Map<String, dynamic> settings) async {
    // This is a stub function that should save settings for a project.
    // Replace with actual code to save to a database or similar storage.
  }

  void updateProjectTimerSettings(int seconds, int shortBreak, int longBreak, SessionType sessionType) async {
    final currentProject = state.currentProject;
    if (currentProject != null) {
      currentProject.timerDuration = seconds;
      currentProject.shortBreakDuration = shortBreak;
      currentProject.longBreakDuration = longBreak;
      currentProject.sessionType = sessionType.name;
      await currentProject.save(); // Persist with Hive
    }
  }

  void _completeSession() {
    _timer?.cancel();
    
    if (_sessionStartTime != null && state.currentProject != null) {
      _saveSession();
    }
    
    state = state.copyWith(status: TimerStatus.completed);
    
    // Auto-transition to next session type
    Timer(const Duration(seconds: 1), () {
      _nextSession();
    });
  }

  void _nextSession() {
    final settings = ref.read(settingsProvider);
    SessionType nextType;
    int nextSession = state.currentSession;
    
    switch (state.sessionType) {
      case SessionType.work:
        nextType = (state.currentSession % 4 == 0) ? SessionType.longBreak : SessionType.shortBreak;
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        nextType = SessionType.work;
        nextSession = state.currentSession + 1;
        break;
    }
    
    final seconds = _getSecondsForSessionType(nextType, settings);
    
    state = state.copyWith(
      sessionType: nextType,
      remainingSeconds: seconds,
      totalSeconds: seconds,
      currentSession: nextSession,
      status: TimerStatus.idle,
    );
  }

  int _getSecondsForSessionType(SessionType type, Settings settings) {
    switch (type) {
      case SessionType.work:
        return settings.pomodoroMinutes * 60;
      case SessionType.shortBreak:
        return settings.shortBreakMinutes * 60;
      case SessionType.longBreak:
        return settings.longBreakMinutes * 60;
    }
  }

  Future<void> _saveSession() async {
    if (_sessionStartTime == null || state.currentProject == null) return;
    bool isIncomplete = state.remainingSeconds > 0;
    
    final session = PomodoroSession(
      id: const Uuid().v4(),
      projectId: state.currentProject!.id,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      duration: state.totalSeconds ~/ 60,
      type: state.sessionType,
      completed: !isIncomplete,
      isIncomplete: isIncomplete,
    );
    
    await DatabaseService.saveSession(session);
    ref.read(sessionsProvider.notifier).loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Sessions provider
final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<PomodoroSession>>((ref) {
  return SessionsNotifier();
});

class SessionsNotifier extends StateNotifier<List<PomodoroSession>> {
  SessionsNotifier() : super([]);

  void loadSessions() {
    state = DatabaseService.getAllSessions();
  }

  List<PomodoroSession> getTodaysSessions() {
    return DatabaseService.getTodaysSessions();
  }

  List<PomodoroSession> getSessionsForProject(String projectId) {
    return DatabaseService.getSessionsForProject(projectId);
  }
}

// Today's sessions provider
final todaysSessionsProvider = Provider<List<PomodoroSession>>((ref) {
  ref.watch(sessionsProvider);
  return DatabaseService.getTodaysSessions();
});

// Sessions by project provider
final sessionsByProjectProvider = Provider<Map<String, List<PomodoroSession>>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final projects = ref.watch(projectsProvider);
  
  final Map<String, List<PomodoroSession>> result = {};
  
  for (final project in projects) {
    result[project.id] = sessions.where((session) => session.projectId == project.id).toList();
  }
  
  return result;
});

final weeklySessionsProvider = Provider<List<PomodoroSession>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1)); // Monday
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  return sessions.where((session) =>
    session.type == SessionType.work &&
    session.completed &&
    session.startTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
    session.startTime.isBefore(endOfWeek)
  ).toList();
});

final weeklySessionsByProjectProvider = Provider<Map<String, List<PomodoroSession>>>((ref) {
  final weeklySessions = ref.watch(weeklySessionsProvider);
  final projects = ref.watch(projectsProvider);

  final Map<String, List<PomodoroSession>> result = {};
  for (final project in projects) {
    result[project.id] = weeklySessions.where((session) => session.projectId == project.id).toList();
  }
  return result;
});
