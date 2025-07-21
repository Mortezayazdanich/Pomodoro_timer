# Mini Timer Feature Documentation

## Overview
The Mini Timer feature provides a compact, always-on-top overlay window that displays the current Pomodoro timer status. This allows users to monitor their timer progress without having to keep the main application window visible.

## Features

### 🖼️ **Pop-out Mini Timer Window**
- **Compact Design**: 280x120 pixel window with essential timer information
- **Always On Top**: Stays visible above all other windows
- **Frameless**: Clean, borderless design that doesn't obstruct the desktop
- **Real-time Updates**: Automatically syncs with the main timer state

### 🎨 **Visual Design**
- **Session-based Color Coding**: 
  - Work Session: Red border and progress bar
  - Short Break: Green border and progress bar  
  - Long Break: Blue border and progress bar
- **Dark Theme**: Semi-transparent black background for minimal distraction
- **Progress Indicator**: Bottom progress bar showing session completion
- **Session Type Badge**: Clearly labeled session type (Work/Short Break/Long Break)

### 🖱️ **Interactive Controls**
- **Draggable**: Click and drag anywhere on the window to reposition
- **Hover Controls**: Close and minimize buttons appear on mouse hover
- **Close Button**: Red circular button to close the mini timer (top-right)
- **Minimize Button**: Orange circular button to move to screen corner (top-right)
- **Click-through Safe**: Buttons are only visible when needed

### 📊 **Information Display**
- **Timer Countdown**: Large, monospace font showing remaining time (MM:SS)
- **Session Type**: Color-coded badge showing current session type
- **Project Name**: Current project name (if available)
- **Visual Progress**: Bottom progress bar showing completion percentage

## How to Use

### 1. **Opening the Mini Timer**
1. Start a Pomodoro session by selecting a project and clicking the play button
2. Click the **Pop-out** button (picture-in-picture icon) in the main timer controls
3. The mini timer window will appear and can be positioned anywhere on screen

### 2. **Positioning the Mini Timer**
- **Manual Positioning**: Click and drag the mini timer window to any screen location
- **Corner Minimization**: Hover over the mini timer and click the orange minimize button to automatically position it in the bottom-right corner

### 3. **Closing the Mini Timer**
- **Hover to Close**: Move your mouse over the mini timer window and click the red close button
- **Main App Control**: The mini timer can also be closed programmatically from the main app
- **No Timer Disruption**: Closing the mini timer does not affect the main timer

### 4. **Monitoring Progress**
- The mini timer automatically updates every second to reflect the current timer state
- The progress bar at the bottom fills as the session progresses
- Colors change automatically when transitioning between work and break sessions

## Technical Implementation

### 🏗️ **Architecture**
- **Multi-Window Support**: Uses Flutter's `desktop_multi_window` package
- **State Synchronization**: Shared Riverpod providers ensure real-time sync
- **Window Management**: `window_manager` package handles window properties
- **Cross-Platform**: Built for Windows with macOS support potential

### 🔧 **Key Components**
- **MiniTimerService**: Handles window creation, positioning, and lifecycle
- **MiniTimerWindow**: Flutter widget providing the mini timer UI
- **WindowListener**: Manages window events and user interactions
- **Riverpod Integration**: Reactive state management for real-time updates

### 🎯 **Window Properties**
- **Size**: 280x120 pixels (fixed)
- **Always On Top**: `setAlwaysOnTop(true)`
- **Skip Taskbar**: `setSkipTaskbar(true)`
- **Frameless**: `setAsFrameless()`
- **Transparent Background**: Semi-transparent overlay design

## Platform Support

### ✅ **Windows**
- **Full Support**: Complete implementation with all features
- **Always On Top**: Native Windows support for overlay windows
- **Window Management**: Full drag, resize, and positioning support
- **Multi-Monitor**: Works across multiple monitor setups

### 🚧 **macOS**
- **Partial Support**: Core functionality available
- **Always On Top**: Supported through window_manager
- **Permissions**: May require accessibility permissions for full functionality
- **Testing Required**: Extensive testing recommended for production use

### ❌ **Linux**
- **Limited Support**: Basic functionality may work
- **Window Manager Dependent**: Behavior varies by desktop environment
- **Always On Top**: Support depends on window manager capabilities
- **Manual Testing Required**: Extensive testing needed

## Troubleshooting

### 🔍 **Common Issues**

#### **Mini Timer Won't Open**
- **Solution**: Ensure a project is selected and timer is active
- **Check**: Verify desktop_multi_window package is properly installed
- **Fallback**: Restart the main application

#### **Window Not Staying On Top**
- **Windows**: Check if "Focus Assist" is blocking the window
- **macOS**: Grant accessibility permissions to the application
- **Linux**: Verify window manager supports always-on-top

#### **Performance Issues**
- **Solution**: Limit to one mini timer window at a time
- **Optimization**: Close other resource-intensive applications
- **Hardware**: Ensure adequate system resources

### 📋 **Best Practices**

#### **Usage Guidelines**
- **Single Instance**: Only open one mini timer at a time
- **Positioning**: Place in a corner to avoid workflow disruption
- **Monitoring**: Use for quick progress checks, not constant focus

#### **Performance Optimization**
- **Close When Not Needed**: Close mini timer when not actively monitoring
- **Minimize Dragging**: Excessive repositioning may impact performance
- **Resource Management**: Monitor system resources on older hardware

## Future Enhancements

### 🔮 **Planned Features**
- **Customizable Size**: Allow users to adjust mini timer dimensions
- **Theme Options**: Light/dark theme toggle for mini timer
- **Opacity Control**: Adjustable transparency levels
- **Sound Notifications**: Audio alerts for session transitions
- **Multiple Monitor Support**: Enhanced multi-monitor positioning

### 🎯 **Advanced Features**
- **Keyboard Shortcuts**: Global hotkeys for mini timer control
- **Auto-hide**: Automatic hiding during full-screen applications
- **Smart Positioning**: Automatic positioning based on active windows
- **Integration**: Deeper integration with system notifications

## API Reference

### **MiniTimerService**
```dart
class MiniTimerService {
  static Future<void> openMiniTimer()
  static Future<void> closeMiniTimer()
  static Future<void> minimizeToCorner()
  static bool get isMiniTimerOpen
  static int? get miniTimerWindowId
}
```

### **Key Methods**
- `openMiniTimer()`: Creates and displays the mini timer window
- `closeMiniTimer()`: Closes the mini timer window
- `minimizeToCorner()`: Positions window in bottom-right corner
- `isMiniTimerOpen`: Returns current mini timer state
- `miniTimerWindowId`: Returns window ID for advanced operations

## Contributing

### 🤝 **Development Guidelines**
- **Testing**: Test on multiple platforms before submitting changes
- **Documentation**: Update documentation for any new features
- **Performance**: Consider performance impact of UI changes
- **Accessibility**: Ensure features work with screen readers

### 📝 **Code Style**
- Follow existing Flutter and Dart style guidelines
- Use meaningful variable names and comments
- Maintain consistent error handling patterns
- Write unit tests for new functionality

---

*This documentation covers the Mini Timer feature implementation. For general application documentation, see the main README file.*
