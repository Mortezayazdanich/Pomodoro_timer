# Pomodoro Timer Installation Guide

## Quick Start

### 1. Using the Cleanup Script (Recommended)
```bash
# Run this to clean lock files and start the app
run_app.bat
```

### 2. Manual Method
```bash
# Clean any existing lock files
dart scripts/cleanup_locks.dart

# Run the app
flutter run -d windows
```

### 3. Build Release Version
```bash
# Build optimized release version
flutter build windows --release

# The executable will be at: build/windows/x64/runner/Release/pomodoro_timer.exe
```

## Common Issues and Solutions

### 🔐 Lock File Access Error
**Error**: `PathAccessException: lock failed, path = 'C:\Users\DNC\Documents\projects.lock'`

**Solution**:
1. Close any running instances of the Pomodoro Timer
2. Run the cleanup script: `dart scripts/cleanup_locks.dart`
3. If the error persists, restart your computer

### 🗂️ Dashboard Widget Error
**Error**: `Bad state: No element`

**Solution**: This is now fixed in the latest version. The dashboard handles empty projects gracefully.

### 🪟 Mini Timer Not Working
**Problem**: Mini timer window doesn't appear or stay on top

**Solutions**:
1. **Windows**: Check if "Focus Assist" is blocking the window
2. **Run as Administrator**: Right-click the app and select "Run as administrator"
3. **Antivirus**: Add the app to your antivirus whitelist

## Features Overview

### ✅ Working Features
- ✅ Pomodoro Timer with customizable durations
- ✅ Project management with color coding
- ✅ Session tracking and analytics
- ✅ **Mini Timer Window** with always-on-top functionality
- ✅ Dark/Light theme support
- ✅ Local data persistence

### 🎯 How to Use Mini Timer
1. Select a project and start the timer
2. Click the **Pop-out** button (picture-in-picture icon)
3. The mini timer window appears and stays on top
4. Drag to reposition anywhere on screen
5. Hover to access close/minimize controls

## System Requirements

### Minimum Requirements
- Windows 10 (64-bit)
- 4GB RAM
- 100MB free disk space
- Flutter SDK (for development)

### Recommended Requirements
- Windows 11 (64-bit)
- 8GB RAM
- 200MB free disk space
- Multiple monitors (for best mini timer experience)

## Development Setup

### Prerequisites
```bash
# Install Flutter
# Download from: https://flutter.dev/docs/get-started/install/windows

# Verify installation
flutter doctor
```

### Dependencies
```bash
# Install dependencies
flutter pub get

# Generate model files
flutter packages pub run build_runner build
```

### Running in Development
```bash
# Clean and run
dart scripts/cleanup_locks.dart
flutter run -d windows

# Hot reload available with 'r' key
# Hot restart available with 'R' key
```

## Troubleshooting Commands

### Clean Everything
```bash
# Clean Flutter build cache
flutter clean

# Clean lock files
dart scripts/cleanup_locks.dart

# Reinstall dependencies
flutter pub get
```

### Check System Status
```bash
# Check Flutter installation
flutter doctor

# Check connected devices
flutter devices

# Verbose analysis
flutter analyze --verbose
```

### Database Issues
```bash
# The app uses Hive for local storage
# Data is stored in: C:\Users\[Username]\AppData\Local\pomodoro_timer\

# To reset all data (WARNING: This deletes all projects and sessions)
# Delete the entire folder: C:\Users\[Username]\AppData\Local\pomodoro_timer\
```

## Performance Tips

### For Better Performance
1. **Close unused applications** when running the timer
2. **Use SSD storage** for faster database access
3. **Enable Hardware Acceleration** in Windows settings
4. **Keep only one mini timer open** at a time

### For Development
1. **Use Hot Reload** (`r` key) instead of restarting
2. **Use Profile Mode** for performance testing: `flutter run --profile`
3. **Enable DevTools** for debugging: `flutter run --debug`

## Support

### Getting Help
1. Check this troubleshooting guide first
2. Run the cleanup script: `dart scripts/cleanup_locks.dart`
3. Check the Flutter doctor: `flutter doctor`
4. Review the error logs in the console

### Reporting Issues
When reporting issues, please include:
- Windows version
- Flutter version (`flutter --version`)
- Error messages (full stack trace)
- Steps to reproduce

## File Structure
```
pomodoro_timer/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── services/                 # Business logic
│   ├── providers/                # State management
│   ├── screens/                  # UI screens
│   └── widgets/                  # Reusable components
├── scripts/
│   └── cleanup_locks.dart        # Lock file cleanup
├── build/
│   └── windows/x64/runner/Release/
│       └── pomodoro_timer.exe    # Built application
└── run_app.bat                   # Quick start script
```

---

**Note**: This application is optimized for Windows. macOS and Linux support may be limited.
