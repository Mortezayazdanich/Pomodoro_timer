import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';

class DashboardWidget extends ConsumerWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysSessions = ref.watch(todaysSessionsProvider);
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    // Group sessions by project
    final sessionsByProject = <String, List<PomodoroSession>>{};
    for (final session in todaysSessions) {
      if (session.type == SessionType.work && session.completed) {
        sessionsByProject.putIfAbsent(session.projectId, () => []);
        sessionsByProject[session.projectId]!.add(session);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (sessionsByProject.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No completed Pomodoros today yet'),
                ),
              )
            else
              Column(
                children: sessionsByProject.entries.map((entry) {
                  final projectId = entry.key;
                  final sessions = entry.value;
                  final project = projects.firstWhere(
                    (p) => p.id == projectId,
                    orElse: () => projects.first,
                  );
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectProgressRow(
                      project: project,
                      completedSessions: sessions.length,
                      totalMinutes: sessions.fold(0, (sum, session) => sum + session.duration),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Today',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SummaryItem(
                        icon: Icons.timer,
                        label: 'Sessions',
                        value: todaysSessions.where((s) => s.type == SessionType.work && s.completed).length.toString(),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      _SummaryItem(
                        icon: Icons.schedule,
                        label: 'Minutes',
                        value: todaysSessions
                            .where((s) => s.type == SessionType.work && s.completed)
                            .fold(0, (sum, session) => sum + session.duration)
                            .toString(),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      _SummaryItem(
                        icon: Icons.folder,
                        label: 'Projects',
                        value: sessionsByProject.length.toString(),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectProgressRow extends StatelessWidget {
  final dynamic project;
  final int completedSessions;
  final int totalMinutes;

  const _ProjectProgressRow({
    required this.project,
    required this.completedSessions,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Color(int.parse(project.color)),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              project.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completedSessions ${completedSessions == 1 ? 'session' : 'sessions'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${totalMinutes}m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
