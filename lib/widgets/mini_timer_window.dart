import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/providers.dart';
import '../models/pomodoro_session.dart';
import '../services/mini_timer_service.dart';
import 'compact_timer_widget.dart';

class MiniTimerWindow extends ConsumerStatefulWidget {
  const MiniTimerWindow({super.key});

  @override
  ConsumerState<MiniTimerWindow> createState() => _MiniTimerWindowState();
}

class _MiniTimerWindowState extends ConsumerState<MiniTimerWindow> with WindowListener {
  bool _isHovered = false;
  bool _isDragging = false;
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initializeWindow();
  }

  Future<void> _initializeWindow() async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setHasShadow(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setSize(const Size(280, 120));
    await windowManager.setResizable(false);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final sessionColor = _getSessionColor(timerState.sessionType);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                _dragOffset = details.localPosition;
              });
            },
            onPanUpdate: (details) async {
              if (_isDragging && _dragOffset != null) {
                final newPosition = details.globalPosition - _dragOffset!;
                await windowManager.setPosition(newPosition);
              }
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
                _dragOffset = null;
              });
            },
            child: Container(
              width: 280,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sessionColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content using CompactTimerWidget
                  const Center(
                    child: CompactTimerWidget(),
                  ),
                  // Close button (shown on hover)
                  if (_isHovered || _isDragging)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => MiniTimerService.closeMiniTimer(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  // Minimize button (shown on hover)
                  if (_isHovered || _isDragging)
                    Positioned(
                      top: 4,
                      right: 28,
                      child: GestureDetector(
                        onTap: () => MiniTimerService.minimizeToCorner(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.minimize,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  // Progress indicator
                  if (timerState.progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 280 * timerState.progress,
                        height: 3,
                        decoration: BoxDecoration(
                          color: sessionColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
