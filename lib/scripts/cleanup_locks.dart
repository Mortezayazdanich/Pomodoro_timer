import 'dart:io';

void main() {
  // List of potential lock file locations
  final lockFilePaths = [
    'C:\\Users\\DNC\\Documents\\projects.lock',
    'C:\\Users\\DNC\\Documents\\sessions.lock',
    'C:\\Users\\DNC\\Documents\\pomodoro_timer\\projects.lock',
    'C:\\Users\\DNC\\Documents\\pomodoro_timer\\sessions.lock',
    'C:\\Users\\DNC\\AppData\\Local\\pomodoro_timer\\projects.lock',
    'C:\\Users\\DNC\\AppData\\Local\\pomodoro_timer\\sessions.lock',
  ];

  for (final path in lockFilePaths) {
    final file = File(path);
    if (file.existsSync()) {
      try {
        file.deleteSync();
        print('Deleted lock file: $path');
      } catch (e) {
        print('Could not delete lock file: $path - $e');
      }
    }
  }
  
  print('Lock file cleanup complete!');
}
