import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';

class MiniTimerWindow extends ConsumerStatefulWidget {
  const MiniTimerWindow({super.key});

  @override
  ConsumerState<MiniTimerWindow> createState() => _MiniTimerWindowState();
}

class _MiniTimerWindowState extends ConsumerState<MiniTimerWindow> with WindowListener {
  bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupMiniWindow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _setupMiniWindow() async {
    if (isDesktop) {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSize(const Size(280, 120));
      await windowManager.setResizable(false);
      await windowManager.setSkipTaskbar(true);
      await windowManager.setTitle('Pomodoro Timer - Mini');
      
      // Position window at top-right of screen
      final screenSize = await windowManager.getSize();
      await windowManager.setPosition(Offset(screenSize.width - 300, 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final currentProject = ref.watch(currentProjectProvider);
    
    return MaterialApp(
      title: 'Mini Timer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Close button
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () async {
                    await windowManager.close();
                  },
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                ),
              ),
              
              // Timer content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Project name
                    if (currentProject != null)
                      Text(
                        currentProject.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 4),
                    
                    // Timer display
                    Text(
                      _formatTime(timerState.remainingSeconds),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timerState.status == TimerStatus.running 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Status indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: timerState.status == TimerStatus.running 
                          ? Colors.green 
                          : timerState.sessionType != SessionType.work 
                            ? Colors.orange 
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
