import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:flutter/services.dart';


class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late TextEditingController _pomodoroController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _pomodoroController = TextEditingController(text: settings.pomodoroMinutes.toString());
    _shortBreakController = TextEditingController(text: settings.shortBreakMinutes.toString());
    _longBreakController = TextEditingController(text: settings.longBreakMinutes.toString());
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _saveSettings(); // Calls the same method as Save button
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true, // Ensure key events are received
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.settings, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Settings'),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Durations (minutes)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pomodoro duration
                  TextFormField(
                    controller: _pomodoroController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pomodoro Session',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work, color: Colors.red.shade600),
                    ),
                    validator: _validateMinutes,
                  ),
                  const SizedBox(height: 16),

                  // Short break duration
                  TextFormField(
                    controller: _shortBreakController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Short Break',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.coffee, color: Colors.green.shade600),
                    ),
                    validator: _validateMinutes,
                  ),
                  const SizedBox(height: 16),

                  // Long break duration
                  TextFormField(
                    controller: _longBreakController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Long Break',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bed, color: Colors.blue.shade600),
                    ),
                    validator: _validateMinutes,
                  ),
                  const SizedBox(height: 16),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Long break occurs after every 4 Pomodoro sessions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _resetToDefaults,
                child: const Text('Reset to Defaults'),
              ),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    
    final minutes = int.tryParse(value);
    if (minutes == null || minutes <= 0) {
      return 'Please enter a positive number';
    }
    
    if (minutes > 60) {
      return 'Duration should not exceed 60 minutes';
    }
    
    return null;
  }

  void _resetToDefaults() {
    setState(() {
      _pomodoroController.text = defaultPomodoroMinutes.toString();
      _shortBreakController.text = defaultShortBreakMinutes.toString();
      _longBreakController.text = defaultLongBreakMinutes.toString();
    });
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final pomodoroMinutes = int.parse(_pomodoroController.text);
      final shortBreakMinutes = int.parse(_shortBreakController.text);
      final longBreakMinutes = int.parse(_longBreakController.text);
      
      ref.read(settingsProvider.notifier).updateSettings(
        pomodoroMinutes: pomodoroMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
      );

      // Updating Project specific timer settings
      final newSessionType = ref.read(timerProvider).sessionType;
      final newSeconds = pomodoroMinutes * 60;
      final newShortBreak = shortBreakMinutes * 60;
      final newLongBreak = longBreakMinutes * 60;
      ref.read(timerProvider.notifier).updateProjectTimerSettings(newSeconds, newShortBreak, newLongBreak, newSessionType);

      // Reset timer to apply new settings
      ref.read(timerProvider.notifier).resetTimer();
      
      Navigator.of(context).pop();
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
