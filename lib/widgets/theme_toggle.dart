import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';


class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    bool isDarkMode;
    if (themeMode == ThemeMode.dark) {
      isDarkMode = true;
    } else if (themeMode == ThemeMode.light) {
      isDarkMode = false;
    } else {
      isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }

    return GestureDetector(
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(
                    themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
              },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? Colors.black87 : Colors.yellow[600],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment:
                  isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  size: 16,
                  color: isDarkMode ? Colors.indigo : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
