import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_controller.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    return Scaffold(
      key: const Key('projects-page'),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-project-button'),
        onPressed: () => _showProjectForm(context),
        icon: const Icon(Icons.add),
        label: Text(strings.get('addProject')),
      ),
      body: controller.projects.isEmpty
          ? Center(child: Text(strings.get('noData')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.projects.length,
              itemBuilder: (context, index) {
                final project = controller.projects[index];
                final progress = (project['progress'] as int? ?? 0).toDouble();
                return Card(
                  key: Key('project-${project['id']}'),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(project['name'] as String),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((project['location'] as String? ?? '').isNotEmpty)
                          Text(project['location'] as String),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress / 100),
                      ],
                    ),
                    trailing: Text('${project['progress'] ?? 0}%'),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showProjectForm(BuildContext context) async {
    final name = TextEditingController();
    final location = TextEditingController();
    final budget = TextEditingController();
    final controller = context.read<AppController>();
    final strings = controller.strings;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('project-dialog'),
        title: Text(strings.get('addProject')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('project-name-field'),
                controller: name,
                decoration: InputDecoration(labelText: strings.get('name')),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('project-location-field'),
                controller: location,
                decoration: InputDecoration(labelText: strings.get('location')),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('project-budget-field'),
                controller: budget,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: strings.get('budget')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.get('cancel')),
          ),
          FilledButton(
            key: const Key('project-save'),
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await controller.repository.insert('projects', {
                'name': name.text.trim(),
                'location': location.text.trim(),
                'budget': double.tryParse(budget.text.trim()) ?? 0,
                'status': 'ongoing',
                'progress': 0,
              });
              await controller.refresh();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(strings.get('save')),
          ),
        ],
      ),
    );
    name.dispose();
    location.dispose();
    budget.dispose();
  }
}
