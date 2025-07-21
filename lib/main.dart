import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'providers/providers.dart';
import 'widgets/mini_timer_window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.initialize();

  // Check for multi-window entrypoint
  if (args.isNotEmpty) {
    try {
      final routeData = jsonDecode(args.first);
      if (routeData['route'] == '/mini_timer') {
        return miniMain(args);
      }
    } catch (e) {
      // If JSON parsing fails, continue with main app
    }
  }

  // Initialize window manager for main app window
  await windowManager.ensureInitialized();
  WindowOptions mainWindowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(400, 300),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(mainWindowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

// Entrypoint for mini-timer window
void miniMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  String? projectId;
  if (args.isNotEmpty) {
    try {
      final routeData = jsonDecode(args.first);
      projectId = routeData['projectId'] as String?;
    } catch (_) {}
  }

  windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(280, 120),
      titleBarStyle: TitleBarStyle.hidden,
      skipTaskbar: true,
      alwaysOnTop: true,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(
    ProviderScope(
      child: MiniTimerWindow(projectId: projectId ?? ''),
    ),
  );
}

// Function to open the mini-timer window
Future<void> openMiniTimerWindow(WidgetRef ref) async {
  final currentProject = ref.read(timerProvider).currentProject;
  if (currentProject == null) return;
  final args = jsonEncode({'projectId': currentProject.id});
  await DesktopMultiWindow.createWindow(args);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);
        return MaterialApp(
          title: 'Pomodoro Timer',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      }
    );
  }
}
