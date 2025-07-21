import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

class MiniTimerService {
  static int? _miniTimerWindowId;
  static bool _isMiniTimerOpen = false;

  /// Opens a new mini timer window
  static Future<void> openMiniTimer() async {
    if (_isMiniTimerOpen) {
      // If mini timer is already open, just focus it
      try {
        if (_miniTimerWindowId != null) {
          await DesktopMultiWindow.invokeMethod(
            _miniTimerWindowId!,
            'focus_window',
          );
        }
        return;
      } catch (e) {
        // If focusing fails, the window might be closed, so continue to create new one
        _isMiniTimerOpen = false;
        _miniTimerWindowId = null;
      }
    }

    try {
      // Create new mini timer window
      final windowController = await DesktopMultiWindow.createWindow(
        jsonEncode({
          'route': '/mini_timer',
          'arguments': {},
        }),
      );

      _miniTimerWindowId = windowController.windowId;
      _isMiniTimerOpen = true;

      // Configure the mini timer window
      windowController
        ..setFrame(Rect.fromLTWH(100, 100, 280, 120))
        ..setTitle('Mini Timer')
        ..show();

    } catch (e) {
      throw Exception('Failed to create mini timer window: ${e.toString()}');
    }
  }

  /// Closes the mini timer window
  static Future<void> closeMiniTimer() async {
    if (_miniTimerWindowId != null) {
      try {
        await DesktopMultiWindow.invokeMethod(
          _miniTimerWindowId!,
          'close_window',
        );
      } catch (e) {
        // Window might already be closed
      }
      _miniTimerWindowId = null;
      _isMiniTimerOpen = false;
    }
  }

  /// Checks if mini timer is currently open
  static bool get isMiniTimerOpen => _isMiniTimerOpen;

  /// Gets the mini timer window ID
  static int? get miniTimerWindowId => _miniTimerWindowId;

  /// Updates mini timer position
  static Future<void> updateMiniTimerPosition(Offset position) async {
    if (_miniTimerWindowId != null) {
      // Positional update logic here if needed.
    }
  }

  /// Minimizes mini timer to corner
  static Future<void> minimizeToCorner() async {
    if (_miniTimerWindowId != null) {
      // Minimize logic here if needed.
    }
  }
}
