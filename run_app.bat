@echo off
echo Cleaning up lock files...
dart scripts/cleanup_locks.dart

echo Starting Pomodoro Timer...
flutter run -d windows

pause
