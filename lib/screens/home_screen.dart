import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/timer_widget.dart';
import '../widgets/project_selector.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/settings_widget.dart';
import '../widgets/theme_toggle.dart';
import '../services/mini_timer_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsProvider.notifier).loadProjects();
      ref.read(sessionsProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final timerState = ref.watch(timerProvider);
        final currentProject = timerState.currentProject;
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.timer, size: 24),
                const SizedBox(width: 8),
                Text(
                  currentProject != null 
                    ? '${currentProject.name} - Pomodoro Timer'
                    : 'Pomodoro Timer',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: [
              // Mini Timer Pop-out button
              // IconButton(
              //   icon: const Icon(Icons.picture_in_picture_alt),
              //   onPressed: timerState.currentProject != null
              //       ? () => _openMiniTimer(context)
              //       : null,
              //   tooltip: 'Open Mini Timer',
              // ),
              // const SizedBox(width: 8),
              // Theme toggle
              const ThemeToggle(),
              const SizedBox(width: 8),
              // Settings button
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(),
                  );
                },
                tooltip: 'Settings',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ProjectSelector(),
                  const SizedBox(height: 24),
                  const TimerWidget(),
                  const SizedBox(height: 24),
                  const DashboardWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMiniTimer(BuildContext context) async {
    try {
      await MiniTimerService.openMiniTimer();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mini timer opened successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open mini timer: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
