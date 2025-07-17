import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Session type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getSessionColor(timerState.sessionType),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getSessionText(timerState.sessionType),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Circular timer
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: CircularProgressPainter(
                      progress: timerState.progress,
                      color: _getSessionColor(timerState.sessionType),
                    ),
                  ),
                  
                  // Timer text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(timerState.remainingSeconds),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: _getSessionColor(timerState.sessionType),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Session ${timerState.currentSession}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Project name
            if (timerState.currentProject != null)
              Text(
                timerState.currentProject!.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset button
                ElevatedButton(
                  onPressed: timerState.currentProject != null
                      ? () => ref.read(timerProvider.notifier).resetTimer()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  child: const Icon(Icons.refresh),
                ),
                
                const SizedBox(width: 16),
                
                // Start/Pause button
                ElevatedButton(
                  onPressed: timerState.currentProject != null
                      ? () => _handlePlayPause(ref, timerState)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getSessionColor(timerState.sessionType),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Icon(
                    timerState.status == TimerStatus.running
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 28,
                  ),
                ),
              ],
            ),
            
            // Status message
            if (timerState.currentProject == null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Select a project to start',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handlePlayPause(WidgetRef ref, TimerState timerState) {
    switch (timerState.status) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        ref.read(timerProvider.notifier).startTimer();
        break;
      case TimerStatus.running:
        ref.read(timerProvider.notifier).pauseTimer();
        break;
      case TimerStatus.paused:
        ref.read(timerProvider.notifier).resumeTimer();
        break;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getSessionText(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Work Session';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Colors.red.shade600;
      case SessionType.shortBreak:
        return Colors.green.shade600;
      case SessionType.longBreak:
        return Colors.blue.shade600;
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(center, radius - 4, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCircle(center: center, radius: radius - 4);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
