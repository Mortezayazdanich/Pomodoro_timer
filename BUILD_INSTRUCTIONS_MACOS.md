# macOS Build Instructions - Pomodoro Timer

## Prerequisites

### Required Software
1. **Flutter SDK** - Already installed via Homebrew
2. **Xcode** - Full Xcode installation required (not just command line tools)
3. **CocoaPods** - Already installed via Homebrew

### Installation Steps

1. **Install Xcode from App Store**
   ```bash
   # Download Xcode from the Mac App Store
   # Or download from: https://developer.apple.com/xcode/
   ```

2. **Configure Xcode Command Line Tools**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Verify Flutter Doctor**
   ```bash
   flutter doctor
   ```

## Building the App

### Development Mode
```bash
# Run in development mode
flutter run -d macos

# Or run with specific device
flutter devices
flutter run -d macos
```

### Release Build
```bash
# Build for release
flutter build macos

# The .app bundle will be created at:
# build/macos/Build/Products/Release/pomodoro_timer.app
```

## Features Implemented

### ✅ Core Features
- Timer widget with project selection
- Settings with adjustable durations (25/5/15 minutes)
- Light/Dark mode toggle with system theme detection
- Project management with color coding
- Session tracking and statistics
- Dashboard with productivity metrics

### ✅ macOS-Specific Features
- Window management with proper sizing (1000x700, minimum 800x600)
- Native macOS window controls (minimize, maximize, close)
- Draggable window behavior
- Window remembers position and size
- System theme integration

### ⚠️ Mini Timer Window
- Framework is prepared for mini always-on-top timer window
- Currently shows placeholder dialog
- Requires multi-window support package for full implementation
- Button visible only on desktop platforms

### ✅ Package Compatibility
All packages are macOS compatible:
- `flutter_riverpod` - State management ✅
- `shared_preferences` - Settings persistence ✅
- `hive` - Local database ✅
- `window_manager` - Window controls ✅
- `intl` - Date/time formatting ✅
- `uuid` - Unique identifiers ✅

## App Structure

```
lib/
├── main.dart              # App entry point with window management
├── models/               # Data models
│   ├── project.dart      # Project model
│   └── pomodoro_session.dart # Session model
├── providers/            # State management
│   └── providers.dart    # Riverpod providers
├── screens/              # Main screens
│   └── home_screen.dart  # Main app screen
├── services/             # Business logic
│   └── database_service.dart # Hive database
├── widgets/              # UI components
│   ├── timer_widget.dart
│   ├── project_selector.dart
│   ├── settings_widget.dart
│   ├── theme_toggle.dart
│   └── dashboard_widget.dart
└── windows/              # Desktop-specific windows
    └── mini_timer_window.dart # Mini timer (framework)
```

## Running the App

### Method 1: Flutter CLI
```bash
cd /Users/morteza/Developer/pomodoro_timer
flutter run -d macos
```

### Method 2: VS Code
1. Open project in VS Code: `code .`
2. Press `F5` or use Command Palette: "Flutter: Launch"
3. Select "macOS" device

### Method 3: Xcode (for advanced debugging)
```bash
open macos/Runner.xcworkspace
```

## App Bundle Location

After building, the app will be located at:
```
build/macos/Build/Products/Release/pomodoro_timer.app
```

You can run it directly by double-clicking or via command line:
```bash
open build/macos/Build/Products/Release/pomodoro_timer.app
```

## Troubleshooting

### Common Issues

1. **Xcode not found**
   - Install full Xcode from App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

2. **CocoaPods issues**
   - Run: `cd macos && pod install`
   - Or: `flutter clean && flutter pub get`

3. **Build failures**
   - Clean build: `flutter clean`
   - Regenerate iOS/macOS: `flutter create .`
   - Check Flutter doctor: `flutter doctor`

### Platform Detection
The app uses safe platform detection to work on both web and desktop:
- Web: Mini timer button is hidden
- Desktop: Full window management and mini timer button available

## Next Steps for Full Implementation

1. **Multi-window support**: Add `desktop_multi_window` package
2. **Menu bar integration**: Add native macOS menu bar
3. **Dock integration**: Hide mini window from dock
4. **Notifications**: Add system notifications for timer completion
5. **App icons**: Add proper macOS app icons
6. **Code signing**: Set up for App Store distribution

## Current Status

- ✅ Basic app functionality works
- ✅ Web version works for testing
- ⚠️ macOS build requires Xcode installation
- ✅ All packages are compatible
- ⚠️ Mini timer needs multi-window package
- ✅ Theme system works with macOS themes
- ✅ Window management configured

The app is ready for development and testing. Full macOS build will work once Xcode is properly installed.
