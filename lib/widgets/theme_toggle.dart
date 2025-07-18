import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Switch(
      value: themeMode == ThemeMode.dark,
      onChanged: (isDark) {
        ref.read(themeModeProvider.notifier)
           .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
      },
    );
  }
}