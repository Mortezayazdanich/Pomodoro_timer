import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/project.dart';

class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final timerState = ref.watch(timerProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Project',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddProjectDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (projects.isEmpty)
              const Center(
                child: Text('No projects yet. Create your first project!'),
              )
            else
              DropdownButtonFormField<Project>(
                value: timerState.currentProject,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a project',
                ),
                items: projects.map((project) {
                  return DropdownMenuItem<Project>(
                    value: project,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(int.parse(project.color)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(project.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (project) {
                  if (project != null) {
                    ref.read(timerProvider.notifier).setProject(project);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );
  }
}

class AddProjectDialog extends ConsumerStatefulWidget {
  const AddProjectDialog({super.key});

  @override
  ConsumerState<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<AddProjectDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  Color _selectedColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Project'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Choose Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addProject,
          child: const Text('Add Project'),
        ),
      ],
    );
  }

  void _addProject() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final colorValue = _selectedColor.value.toString();
      
      await ref.read(projectsProvider.notifier).addProject(name, colorValue);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
