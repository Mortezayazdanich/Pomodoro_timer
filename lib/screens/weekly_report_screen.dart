import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final weeklySessions = _filterWeeklySessions(sessions);
    final totalSessions = weeklySessions.length;
    final halfFinishedSessions = weeklySessions.where((s) => s.isIncomplete).length;
    final totalMinutes = weeklySessions.fold(0, (sum, session) => sum + session.duration);
    final mostActiveDay = _findMostActiveDay(weeklySessions);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Pomodoros Completed: $totalSessions'),
            Text('Half-Finished Sessions: $halfFinishedSessions'),
            Text('Total Focus Time: ${_formatDuration(totalMinutes)}'),
            Text('Most Active Day: $mostActiveDay'),
          ],
        ),
      ),
    );
  }

  List<PomodoroSession> _filterWeeklySessions(List<PomodoroSession> sessions) {
    final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    return sessions.where((session) => session.startTime.isAfter(startOfWeek)).toList();
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
