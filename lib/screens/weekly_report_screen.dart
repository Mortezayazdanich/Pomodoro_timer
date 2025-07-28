import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/project.dart';
import '../models/pomodoro_session.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final weeklySessionsByProject = ref.watch(weeklySessionsByProjectProvider);

    // Calculate total time per project
    final projectTimes = projects.map((project) {
      final sessions = weeklySessionsByProject[project.id] ?? [];
      final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.duration);
      return {
        'project': project,
        'minutes': totalMinutes,
      };
    }).where((entry) => (entry['minutes'] as int) > 0).toList();

    // Sort by time spent descending
    projectTimes.sort((a, b) =>
      (b['minutes'] as int).compareTo(a['minutes'] as int)
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: projectTimes.isEmpty
            ? Center(child: Text('No activity this week', style: Theme.of(context).textTheme.titleMedium))
            : ListView(
                children: [
                  Text('Weekly Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...projectTimes.map((entry) {
                    final project = entry['project'] as Project;
                    final minutes = entry['minutes'] as int;
                    final hours = minutes ~/ 60;
                    final mins = minutes % 60;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(int.parse(project.color)),
                          child: Text(project.name[0]),
                        ),
                        title: Text(project.name),
                        subtitle: Text('Focus Time: ${hours}h ${mins}m'),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
