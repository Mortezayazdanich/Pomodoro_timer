import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';

class CompactTimerWidget extends ConsumerWidget {
  const CompactTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular timer
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress circle
              CustomPaint(
                size: const Size(80, 80),
                painter: CircularProgressPainter(
                  progress: timerState.progress,
                  color: _getSessionColor(timerState.sessionType),
                ),
              ),
              
              // Timer text
              Text(
                _formatTime(timerState.remainingSeconds),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Session type text
        Text(
          _getSessionText(timerState.sessionType),
          style: TextStyle(
            fontSize: 12,
            color: _getSessionColor(timerState.sessionType),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Project name
        if (timerState.currentProject != null)
          Text(
            timerState.currentProject!.name,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
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
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius - 2, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCircle(center: center, radius: radius - 2);
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
