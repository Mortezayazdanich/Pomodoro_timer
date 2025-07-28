import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'widgets/mini_timer_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: MiniTimerWindow(projectId: ''),
    ),
  );
}
