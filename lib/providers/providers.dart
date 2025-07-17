import 'dart:async';
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
    final settings = ref.read(settingsProvider);
    final seconds = _getSecondsForSessionType(SessionType.work, settings);
    
    state = state.copyWith(
      currentProject: project,
      sessionType: SessionType.work,
      remainingSeconds: seconds,
      totalSeconds: seconds,
      currentSession: 1,
      status: TimerStatus.idle,
    );
  }

  void _completeSession() {
    _timer?.cancel();
    
    if (_sessionStartTime != null && state.currentProject != null) {
      _saveSession();
    }
    
    state = state.copyWith(status: TimerStatus.completed);
    
    // Auto-transition to next session type
    Timer(const Duration(seconds: 2), () {
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
    
    final session = PomodoroSession(
      id: const Uuid().v4(),
      projectId: state.currentProject!.id,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      duration: state.totalSeconds ~/ 60,
      type: state.sessionType,
      completed: true,
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
