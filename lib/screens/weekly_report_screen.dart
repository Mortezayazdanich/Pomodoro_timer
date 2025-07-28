import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';
import '../models/project.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final projects = ref.watch(projectsProvider);
    final weeklySessions = _filterWeeklySessions(sessions);

    // Overview stats (only 'work' sessions)
    final focusSessions = weeklySessions.where((s) => s.type == SessionType.work).toList();
    final totalSessions = focusSessions.length;
    final halfFinishedSessions = focusSessions.where((s) => s.isIncomplete).length;
    final totalMinutes = focusSessions.fold(0, (sum, session) => sum + session.duration);
    final mostActiveDay = _findMostActiveDay(focusSessions);

    // Group sessions by project (only 'work' sessions)
    final Map<String, List<PomodoroSession>> sessionsByProject = {};
    for (var session in focusSessions) {
      sessionsByProject.putIfAbsent(session.projectId, () => []).add(session);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview section
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Total Pomodoros Completed: $totalSessions'),
            Text('Half-Finished Sessions: $halfFinishedSessions'),
            Text('Total Focus Time: ${_formatDuration(totalMinutes)}'),
            Text('Most Active Day: $mostActiveDay'),
            const Divider(height: 32),

            // Per-project breakdown
            Text('Projects', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...projects.map((project) {
              final projectSessions = sessionsByProject[project.id] ?? [];
              final completed = projectSessions.length;
              final halfFinished = projectSessions.where((s) => s.isIncomplete).length;
              final focusMinutes = projectSessions.fold(0, (sum, s) => sum + s.duration);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: Theme.of(context).textTheme.titleSmall),
                      Text('Pomodoros: $completed'),
                      Text('Half-Finished: $halfFinished'),
                      Text('Focus Time: ${_formatDuration(focusMinutes)}'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<PomodoroSession> _filterWeeklySessions(List<PomodoroSession> sessions) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return sessions.where((session) =>
      session.startTime.isAtSameMomentAs(startOfWeek) ||
      (session.startTime.isAfter(startOfWeek) && session.startTime.isBefore(endOfWeek))
    ).toList();
  }

  String _findMostActiveDay(List<PomodoroSession> sessions) {
    final counts = List<int>.filled(7, 0);
    for (var session in sessions) {
      counts[session.startTime.weekday - 1]++;
    }
    final mostActiveIndex = counts.indexWhere((count) => count == counts.reduce((a, b) => a > b ? a : b));
    return DateFormat('EEEE').format(DateTime.now().add(Duration(days: mostActiveIndex)));
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return "${hours}h ${minutes}m";
  }
}
